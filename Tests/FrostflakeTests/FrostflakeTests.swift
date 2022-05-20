@testable import Frostflake
@testable import SwiftFrostflake

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

    func testUnixEpochConversion() {
        var unixEpoch = EpochDateTime.unixEpoch()
        unixEpoch.convert(timestamp: 1653051594)
        // EpochDateTime(year: 2022, month: 5, day: 20, hour: 12, minute: 59, second: 54)
        XCTAssert(unixEpoch.year == 2022 &&
                  unixEpoch.month == 5 &&
                  unixEpoch.day == 20 &&
                  unixEpoch.hour == 12 &&
                  unixEpoch.minute == 59 &&
                  unixEpoch.second == 54, "Unix epoch conversion did not produce expected result")
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
