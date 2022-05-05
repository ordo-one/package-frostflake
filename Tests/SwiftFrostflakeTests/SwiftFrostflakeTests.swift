@testable import Frostflake
import XCTest

final class SwiftFrostflakeTests: XCTestCase {
    private let classGeneratorCount = 1_000
    private let classIterationCount = 1_000
    private let actorGeneratorCount = 1_000
    private let actorIterationCount = 1_000

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFrostflakeClassOutput() async {
        let frostflakeGenerator = FrostflakeActor(generatorIdentifier: 1_000)

        for _ in 0 ..< 10 {
            let frostflake = await frostflakeGenerator.generatorFrostflakeIdentifier()
            let decription = frostflake.frostflakeDescription()
            print(decription)
        }
    }

    func testFrostflakeActor() async {
        for generatorId in 0 ..< actorGeneratorCount {
            let frostflakeGenerator = FrostflakeActor(generatorIdentifier: UInt16(generatorId))

            for _ in 0 ..< actorIterationCount {
                blackHole(await frostflakeGenerator.generatorFrostflakeIdentifier())
            }
        }
    }

    func testFrostflake() async {
        for generatorId in 0 ..< classGeneratorCount {
            let frostflakeGenerator = Frostflake(generatorIdentifier: UInt16(generatorId))

            for _ in 0 ..< classIterationCount {
                blackHole(frostflakeGenerator.generatorFrostflakeIdentifier())
            }
        }
    }

    func testFrostflakeClassWithoutLocks() async {
        for generatorId in 0 ..< classGeneratorCount {
            let frostflakeGenerator = Frostflake(generatorIdentifier: UInt16(generatorId),
                                                      concurrentAccess: false)

            for _ in 0 ..< classIterationCount {
                blackHole(frostflakeGenerator.generatorFrostflakeIdentifier())
            }
        }
    }

    func testFrostflakeClassOverflowNextSecond() {
        let frostflakeGenerator = Frostflake(generatorIdentifier: 0)

        for _ in 1 ..< 1 << sequenceNumberBits {
            blackHole(frostflakeGenerator.generatorFrostflakeIdentifier())
        }

        sleep(1) // Needed so that we don't overflow the sequenceNumberBits in the same second

        for _ in 1 ..< 1 << sequenceNumberBits {
            blackHole(frostflakeGenerator.generatorFrostflakeIdentifier())
        }
    }

    func testFrostflakeActorOverflowNextSecond() async {
        let frostflakeGenerator = FrostflakeActor(generatorIdentifier: 0)

        for _ in 1 ..< 1 << sequenceNumberBits {
            blackHole(await frostflakeGenerator.generatorFrostflakeIdentifier())
        }

        sleep(1) // Needed so that we don't overflow the sequenceNumberBits in the same second

        for _ in 1 ..< 1 << sequenceNumberBits {
            blackHole(await frostflakeGenerator.generatorFrostflakeIdentifier())
        }
    }
}
