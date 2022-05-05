import ArgumentParser
import Frostflake

let classGeneratorCount = 125
let classIterationCount = 1_000_000
let actorGeneratorCount = 18
let actorIterationCount = 1_000_000
let classTotalCount = classGeneratorCount * classIterationCount
let actorTotalCount = actorGeneratorCount * actorIterationCount

@main
struct SwiftFrostflake: AsyncParsableCommand {
    @Flag(help: "Run with actor implementation")
    var actorImplementation = false

    static func frostflakeActorBenchmark() async {
        for generatorId in 0 ..< actorGeneratorCount {
            let frostflakeGenerator = Frostflake(generatorIdentifier: UInt16(generatorId))

            for _ in 0 ..< actorIterationCount {
                blackHole(await frostflakeGenerator.generatorFrostflakeIdentifier())
            }
        }
    }

    static func frostflakeClassBenchmark() async {
        for generatorId in 0 ..< classGeneratorCount {
            let frostflakeGenerator = FrostflakeClass(generatorIdentifier: UInt16(generatorId))

            for _ in 0 ..< classIterationCount {
                blackHole(frostflakeGenerator.generatorFrostflakeIdentifier())
            }
        }
    }

    mutating func run() async throws {
        await withTaskGroup(of: Void.self) { taskGroup in
            if actorImplementation {
                taskGroup.addTask { await Self.frostflakeActorBenchmark() }
            } else {
                taskGroup.addTask { await Self.frostflakeClassBenchmark() }
            }
        }
    }
}
