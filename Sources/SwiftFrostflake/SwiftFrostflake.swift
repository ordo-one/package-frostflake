import ArgumentParser
import Frostflake

let classGeneratorCount = 1
let classIterationCount = 999_999
let classTotalCount = classGeneratorCount * classIterationCount

@main
struct SwiftFrostflake: AsyncParsableCommand {
    @Flag(help: "Run with unprotected class implementation without locks")
    var skipLocks = false

    @Flag(help: "Use generatorIdentifier to create Frostlake based on it")
    var generatorIdentifier = false

    @Argument(help: "Provide Frostflake ID(default) or Generator ID or 'benchmark' command")
    var identifierOrCommand: String

    static func frostflakeBenchmark(noLocks: Bool) async {
        for generatorId in 0 ..< classGeneratorCount {
            let frostflakeGenerator = Frostflake(generatorIdentifier: UInt16(generatorId),
                                                 concurrentAccess: !noLocks)

            for _ in 0 ..< classIterationCount {
                blackHole(frostflakeGenerator.generatorFrostflakeIdentifier())
            }
        }
    }

    mutating func run() async throws {
        if identifierOrCommand == "benchmark" {
            let locks = skipLocks
            await withTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask { await Self.frostflakeBenchmark(noLocks: locks) }
                print("Generated \(classTotalCount) Frostflakes")
            }
        } else {
            if let identifier = UInt64(identifierOrCommand) {
                if generatorIdentifier {
                    guard 0 ..< 4_096 ~= identifier else {
                        print("generatorIdentifier should be in range from 0 to 4095")
                        return
                    }
                    let frostflakeGenerator = Frostflake(generatorIdentifier: UInt16(identifier),
                                                         concurrentAccess: false)
                    print("Snowflake ID: \(frostflakeGenerator.generatorFrostflakeIdentifier())")
                } else {
                    guard identifier > 0 else {
                        print("frostFlake ID should be grater than 0")
                        return
                    }
                    print("Frostflake description: \(identifier.frostflakeDescription())")
                }
            } else {
                print("Unknown argument, it should be 'benchmack' or identifier")
            }
        }
    }
}
