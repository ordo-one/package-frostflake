@testable import DateTime
@testable import Frostflake

import XCTest

#if canImport(Darwin)
    import Darwin
#endif

final class FrostflakeTests: XCTestCase {
    private let generatorIdentifierMax = 2

    override class func setUp() {
        #if canImport(Darwin)
            atexit(leaksExit)
        #endif
    }

    // Verified using https://www.epochconverter.com as well manually
    func testUnixEpochConversion() {
        var unixEpoch = EpochDateTime.unixEpoch()
        unixEpoch.convert(timestamp: 1_653_051_594)
        // EpochDateTime(year: 2022, month: 5, day: 20, hour: 12, minute: 59, second: 54)
        XCTAssert(unixEpoch.year == 2_022 &&
            unixEpoch.month == 5 &&
            unixEpoch.day == 20 &&
            unixEpoch.hour == 12 &&
            unixEpoch.minute == 59 &&
            unixEpoch.second == 54, "Unix epoch conversion did not produce expected result")
    }

    func testUnixEpochWithFutureDate() {
        var unixEpoch = EpochDateTime.unixEpoch()
        unixEpoch.convert(timestamp: 19_912_223_655)
        // EpochDateTime(year: 2600, month: 12, day: 29, hour: 13, minute: 14, second: 15)
        XCTAssert(unixEpoch.year == 2_600 &&
            unixEpoch.month == 12 &&
            unixEpoch.day == 29 &&
            unixEpoch.hour == 13 &&
            unixEpoch.minute == 14 &&
            unixEpoch.second == 15, "Unix epoch conversion did not produce expected result")
    }

    func testTestEpochWithFutureDate() {
        var testEpoch = EpochDateTime.testEpoch()
        testEpoch.convert(timestamp: 6_001) // + 100 minutes

        // EpochDateTime(year: 2022, month: 5, day: 20, hour: 15, minute: 40, second: 1)
        XCTAssert(testEpoch.year == 2_022 &&
            testEpoch.month == 5 &&
            testEpoch.day == 20 &&
            testEpoch.hour == 15 &&
            testEpoch.minute == 40 &&
            testEpoch.second == 1, "Unix epoch conversion did not produce expected result")
    }

    func testFrostflakeClassOutput() async {
        let frostflakeFactory = Frostflake(generatorIdentifier: 1_000)

        for _ in 0 ..< 10 {
            let frostflake = frostflakeFactory.generate()
            let decription = frostflake.frostflakeDescription()
            print(decription)
        }
    }

    func testFrostflake() async {
        XCTAssert(Frostflake.validGeneratorIdentifierRange.contains(generatorIdentifierMax))
        for generatorId in 0 ..< generatorIdentifierMax {
            let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(generatorId))

            for _ in Frostflake.allowedSequenceNumberRange {
                blackHole(frostflakeFactory.generate())
            }
        }
    }

    func testFrostflakeClassWithoutLocks() async {
        XCTAssert(Frostflake.validGeneratorIdentifierRange.contains(generatorIdentifierMax))
        for generatorId in 0 ..< generatorIdentifierMax {
            let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(generatorId),
                                               concurrentAccess: false)

            for _ in Frostflake.allowedSequenceNumberRange {
                blackHole(frostflakeFactory.generate())
            }
        }
    }

    func testFrostflakeClassOverflowNextSecond() {
        let frostflakeFactory = Frostflake(generatorIdentifier: 0)

        for _ in Frostflake.allowedSequenceNumberRange {
            blackHole(frostflakeFactory.generate())
        }

        sleep(1) // Needed so that we don't overflow the sequenceNumberBits in the same second

        for _ in Frostflake.allowedSequenceNumberRange {
            blackHole(frostflakeFactory.generate())
        }
    }

    func testFrostflakeSharedGenerator() {
        let frostflake = Frostflake(generatorIdentifier: 47)

        Frostflake.setup(sharedGenerator: frostflake)

        for _ in Frostflake.allowedSequenceNumberRange {
            blackHole(Frostflake.generate())
        }
    }

    // Regression test for sc-493
    func testIncorrectForcingSecondRegenerationInterval() {
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(100))
        for _ in Frostflake.allowedSequenceNumberRange {
            blackHole(frostflakeFactory.generate())
        }
        sleep(2)
        for _ in Frostflake.allowedSequenceNumberRange {
            blackHole(frostflakeFactory.generate())
        }
    }
}
