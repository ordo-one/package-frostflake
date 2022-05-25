import ArgumentParser
import Frostflake

@main
struct SwiftFrostflake: AsyncParsableCommand {
    @Flag(help: "Use generatorIdentifier to create Frostlake based on it")
    var generatorIdentifier = false

    @Argument(help: "Provide Frostflake ID(default) or Generator ID")
    var identifier: UInt64

    mutating func run() async throws {
        if identifier > 0 {
            if generatorIdentifier {
                guard 0 ..< (1 << generatorIdentifierBits) ~= identifier else {
                    print("generatorIdentifier should be in range from 0 to \((1 << generatorIdentifierBits) - 1)")
                    return
                }
                let frostflakeGenerator = Frostflake(generatorIdentifier: UInt16(identifier),
                                                     concurrentAccess: false)
                print("Frostflake ID: \(frostflakeGenerator.generatorFrostflakeIdentifier())")
            } else {
                print("Frostflake description: \(identifier.frostflakeDescription())")
            }
        } else {
            print("Unknown argument, it should be Int identifier and greater than 0")
        }
    }
}
