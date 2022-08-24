import ArgumentParser
import Frostflake
import SystemPackage
import Benchmark
import ExtrasJSON

let classGeneratorCount = 1
let classIterationCount = 999_999
let classTotalCount = classGeneratorCount * classIterationCount

let sharedGenerator = true

@main
struct FrostflakeBenchmark: AsyncParsableCommand {
    @Flag(help: "Run with unprotected class implementation without locks")
    var skipLocks = false

    @Option(name: .shortAndLong, help: "The input pipe filedescriptor used for communication with host process.")
    var inputFD: Int32

    @Option(name: .shortAndLong, help: "The output pipe filedescriptor used for communication with host process.")
    var outputFD: Int32

    static func frostflakeBenchmark(noLocks: Bool) async {
        if sharedGenerator {
            let frostflake = Frostflake(generatorIdentifier: 0)
            Frostflake.setup(sharedGenerator: frostflake)

            for _ in 0 ..< classIterationCount {
                blackHole(Frostflake.generate())
            }
        } else {
            for generatorId in 0 ..< classGeneratorCount {
                let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(generatorId),
                                                   concurrentAccess: !noLocks)

                for _ in 0 ..< classIterationCount {
                    blackHole(frostflakeFactory.generate())
                }
            }
        }
    }

    mutating func run() async throws {
        let locks = skipLocks
        print("inputFD = \(inputFD)")
        print("outputFD = \(outputFD)")

        let input = FileDescriptor.init(rawValue: inputFD)
        let output = FileDescriptor.init(rawValue: outputFD)
        var bufferLength: Int = 0
        var count: Int = 0

        try withUnsafeMutableBytes(of: &bufferLength) { (intPtr: UnsafeMutableRawBufferPointer) in
            count = try input.read(into: intPtr)
        }
        print("Read \(count) bytes, \(bufferLength)")

        let readBytes = try Array<UInt8>(unsafeUninitializedCapacity: bufferLength) { buf, count in
            count = try input.read(into: UnsafeMutableRawBufferPointer(buf))
        }

        print("Read \(readBytes.count) bytes into \(readBytes.debugDescription)")

        let benchmarkCommand = try XJSONDecoder().decode(BenchmarkCommand.self, from: readBytes)

        print("benchmarkCommand is \(benchmarkCommand)")

        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask { await Self.frostflakeBenchmark(noLocks: locks) }
        }
        print("Generated \(classTotalCount) Frostflakes")
    }
}
