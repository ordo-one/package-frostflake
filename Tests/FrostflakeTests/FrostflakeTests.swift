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

    func testUnixEpochWithFutureDate() {
        var unixEpoch = EpochDateTime.unixEpoch()
        unixEpoch.convert(timestamp: 19912223655)
        // EpochDateTime(year: 2600, month: 12, day: 29, hour: 13, minute: 14, second: 15)
        XCTAssert(unixEpoch.year == 2600 &&
                  unixEpoch.month == 12 &&
                  unixEpoch.day == 29 &&
                  unixEpoch.hour == 13 &&
                  unixEpoch.minute == 14 &&
                  unixEpoch.second == 15, "Unix epoch conversion did not produce expected result")
    }

    func testTestEpochWithFutureDate() {
        var testEpoch = EpochDateTime.testEpoch()
        testEpoch.convert(timestamp: 6001) // + 100 minutes

        // EpochDateTime(year: 2022, month: 5, day: 20, hour: 15, minute: 40, second: 1)
        XCTAssert(testEpoch.year == 2022 &&
                  testEpoch.month == 5 &&
                  testEpoch.day == 20 &&
                  testEpoch.hour == 15 &&
                  testEpoch.minute == 40 &&
                  testEpoch.second == 1, "Unix epoch conversion did not produce expected result")
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
