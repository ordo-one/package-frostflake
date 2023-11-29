// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

@testable import DateTime
@testable import Frostflake

import XCTest

final class FrostflakeTests: XCTestCase {
    private let smallRangeTest = 1 ..< 1_000

    override class func setUp() {
        let frostflake = Frostflake(generatorIdentifier: 47)
        Frostflake.setup(sharedGenerator: frostflake)
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
        testEpoch.convert(timestamp: 1653061201) // + 100 minutes

        // EpochDateTime(year: 2022, month: 5, day: 20, hour: 15, minute: 40, second: 1)
        XCTAssertEqual(testEpoch.year, 2_022)
        XCTAssertEqual(testEpoch.month, 5)
        XCTAssertEqual(testEpoch.day, 20)
        XCTAssertEqual(testEpoch.hour, 15)
        XCTAssertEqual(testEpoch.minute, 40)
        XCTAssertEqual(testEpoch.second, 1)
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
        for generatorId in smallRangeTest {
            let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(generatorId))

            for _ in smallRangeTest {
                blackHole(frostflakeFactory.generate())
            }
        }
    }

    func testFrostflakeClassWithoutLocks() async {
        for generatorId in smallRangeTest {
            let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(generatorId),
                                               concurrentAccess: false)

            for _ in smallRangeTest {
                blackHole(frostflakeFactory.generate())
            }
        }
    }

    func testFrostflakeClassOverflowNextSecond() {
        let frostflakeFactory = Frostflake(generatorIdentifier: 0)

        for _ in 1 ..< Frostflake.allowedSequenceNumberRange.upperBound {
            blackHole(frostflakeFactory.generate())
        }

        sleep(1) // Needed so that we don't overflow the sequenceNumberBits in the same second

        for _ in 1 ..< Frostflake.allowedSequenceNumberRange.upperBound {
            blackHole(frostflakeFactory.generate())
        }
    }

    func testFrostflakeSharedGenerator() {
        for _ in smallRangeTest {
            blackHole(Frostflake.generate())
        }
    }

    func testFrostflakeSharedGeneratorWithCustomInit() {
        for _ in smallRangeTest {
            blackHole(FrostflakeIdentifier())
        }
    }

    // Regression test for sc-493
    func testIncorrectForcingSecondRegenerationInterval() {
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(100))
        for _ in 1 ..< Frostflake.allowedSequenceNumberRange.upperBound {
            blackHole(frostflakeFactory.generate())
        }
        sleep(1)
        for _ in 1 ..< Frostflake.allowedSequenceNumberRange.upperBound {
            blackHole(frostflakeFactory.generate())
        }
    }
}
