@testable import Frostflake

import XCTest

#if canImport(Darwin)
    import Darwin
#endif

final class SwiftFrostflakeTests: XCTestCase {
    private let classGeneratorCount = 1_000
    private let classIterationCount = 1_000

    override class func setUp() {
        #if canImport(Darwin)
            atexit(leaksExit)
        #endif
    }

    func testFrostflakeClassOutput() async {
        let frostflakeGenerator = Frostflake(generatorIdentifier: 1_000)

        for _ in 0 ..< 10 {
            let frostflake = frostflakeGenerator.generatorFrostflakeIdentifier()
            let decription = frostflake.frostflakeDescription()
            print(decription)
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
}
