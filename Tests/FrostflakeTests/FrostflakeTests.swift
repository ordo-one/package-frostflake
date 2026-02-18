// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import Foundation
import Frostflake
import Testing

@Suite("Frostflake Tests")
struct FrostflakeTests {
    private let smallRangeTest = 1 ..< 1_000

    // Verified using https://www.epochconverter.com as well manually
    @Test("Unix epoch conversion produces correct date components")
    func unixEpochConversion() {
        var unixEpoch = EpochDateTime.unixEpoch()
        unixEpoch.convert(timestamp: 1_653_051_594)
        // EpochDateTime(year: 2022, month: 5, day: 20, hour: 12, minute: 59, second: 54)
        #expect(unixEpoch.year == 2_022 &&
            unixEpoch.month == 5 &&
            unixEpoch.day == 20 &&
            unixEpoch.hour == 12 &&
            unixEpoch.minute == 59 &&
            unixEpoch.second == 54, "Unix epoch conversion did not produce expected result")
    }

    @Test("Unix epoch conversion handles future dates correctly")
    func unixEpochWithFutureDate() {
        var unixEpoch = EpochDateTime.unixEpoch()
        unixEpoch.convert(timestamp: 19_912_223_655)
        // EpochDateTime(year: 2600, month: 12, day: 29, hour: 13, minute: 14, second: 15)
        #expect(unixEpoch.year == 2_600 &&
            unixEpoch.month == 12 &&
            unixEpoch.day == 29 &&
            unixEpoch.hour == 13 &&
            unixEpoch.minute == 14 &&
            unixEpoch.second == 15, "Unix epoch conversion did not produce expected result")
    }

    @Test("Test epoch conversion handles future dates correctly")
    func testEpochWithFutureDate() {
        var testEpoch = EpochDateTime.testEpoch()
        testEpoch.convert(timestamp: 1_653_061_201) // + 100 minutes

        // EpochDateTime(year: 2022, month: 5, day: 20, hour: 15, minute: 40, second: 1)
        #expect(testEpoch.year == 2_022)
        #expect(testEpoch.month == 5)
        #expect(testEpoch.day == 20)
        #expect(testEpoch.hour == 15)
        #expect(testEpoch.minute == 40)
        #expect(testEpoch.second == 1)
        #expect(testEpoch.year == 2_022 &&
            testEpoch.month == 5 &&
            testEpoch.day == 20 &&
            testEpoch.hour == 15 &&
            testEpoch.minute == 40 &&
            testEpoch.second == 1, "Unix epoch conversion did not produce expected result")
    }

    @Test("Frostflake generates valid debug descriptions")
    func frostflakeClassOutput() async {
        let frostflakeFactory = Frostflake(generatorIdentifier: 1_000)

        for _ in 0 ..< 10 {
            let frostflake = frostflakeFactory.generate()
            blackHole(frostflake.debugDescription)
        }
    }

    @Test("Frostflake generates unique identifiers across multiple generators")
    func frostflake() async {
        for generatorId in smallRangeTest {
            let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(generatorId))

            for _ in smallRangeTest {
                blackHole(frostflakeFactory.generate())
            }
        }
    }

    @Test("Frostflake works correctly without concurrent access locks")
    func frostflakeClassWithoutLocks() async {
        for generatorId in smallRangeTest {
            let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(generatorId),
                                               concurrentAccess: false)

            for _ in smallRangeTest {
                blackHole(frostflakeFactory.generate())
            }
        }
    }

    @Test("Frostflake handles sequence overflow by waiting for next second")
    func frostflakeClassOverflowNextSecond() {
        let frostflakeFactory = Frostflake(generatorIdentifier: 0)

        for _ in 1 ..< Frostflake.allowedSequenceNumberRange.upperBound {
            blackHole(frostflakeFactory.generate())
        }

        sleep(1) // Needed so that we don't overflow the sequenceNumberBits in the same second

        for _ in 1 ..< Frostflake.allowedSequenceNumberRange.upperBound {
            blackHole(frostflakeFactory.generate())
        }
    }

    // Regression test for unsynchronized state not being written back (sc-29118)
    @Test("Unsynchronized generator persists sequence number between calls")
    func unsynchronizedStatePersistence() {
        let frostflakeFactory = Frostflake(generatorIdentifier: 1, concurrentAccess: false)
        let first = frostflakeFactory.generate()
        let second = frostflakeFactory.generate()
        #expect(first.rawValue != second.rawValue, "Sequential generates must produce unique identifiers")
        #expect(frostflakeFactory.sequenceNumber == 2,
                "Sequence number must advance across calls, got \(frostflakeFactory.sequenceNumber)")
    }

    // Regression test for sc-493
    @Test("Sequence regeneration interval resets correctly after overflow")
    func incorrectForcingSecondRegenerationInterval() {
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
