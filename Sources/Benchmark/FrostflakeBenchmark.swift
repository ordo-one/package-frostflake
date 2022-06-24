import ArgumentParser
import Frostflake

let classGeneratorCount = 1
let classIterationCount = 999_999
let classTotalCount = classGeneratorCount * classIterationCount

let sharedGenerator = true

@main
struct FrostflakeBenchmark: AsyncParsableCommand {
    @Flag(help: "Run with unprotected class implementation without locks")
    var skipLocks = false

    static func frostflakeBenchmark(noLocks: Bool) async {
        if sharedGenerator {
            Frostflake.setup(generatorIdentifier: 0)

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
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask { await Self.frostflakeBenchmark(noLocks: locks) }
        }
        print("Generated \(classTotalCount) Frostflakes")
    }
}
