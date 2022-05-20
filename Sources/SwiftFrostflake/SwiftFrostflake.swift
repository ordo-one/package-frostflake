import ArgumentParser
import Frostflake

let classGeneratorCount = 129
let classIterationCount = 1_000_000
let classTotalCount = classGeneratorCount * classIterationCount

// We should modify this command line tool to be able to parse out timestamp and identifier
// from a Frostflake and to be able to generate an identifier for a given generator id.
@main
struct SwiftFrostflake: AsyncParsableCommand {
    @Flag(help: "Run with unprotected class implementation without locks")
    var skipLocks = false

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
        let locks = skipLocks
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask { await Self.frostflakeBenchmark(noLocks: locks) }
        }
    }
}
