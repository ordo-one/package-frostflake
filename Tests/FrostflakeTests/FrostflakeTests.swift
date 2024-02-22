// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

@testable import FrostflakeKit

import XCTest

final class FrostflakeTests: XCTestCase {
    private let smallRangeTest = 1 ..< 1_000

    override class func setUp() {
        let frostflake = Frostflake(generatorIdentifier: 47)
        Frostflake.setup(sharedGenerator: frostflake)
    }

    func testFrostflakeClassOutput() async {
        let frostflakeFactory = Frostflake(generatorIdentifier: 1_000)

        for _ in 0 ..< 10 {
            let frostflake = frostflakeFactory.generate()
            let decription = frostflake.frostflakeDescription()
            blackHole(decription)
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

    func testDoubleSetup() {
        let frostflake = Frostflake(generatorIdentifier: 47)
        Frostflake.setup(sharedGenerator: frostflake)
    }

    func testFrostflakeDescription() {
        let frostflake: FrostflakeIdentifier = 7_319_193_677_673_271_295
        XCTAssertEqual(frostflake.frostflakeDescription(),
                       "7319193677673271295 (2024-01-01 18:09:35 UTC, sequenceNumber:1, generatorIdentifier:2047)")
    }

    func testFrostflakeIdentifierBase58() {
        let frostflakeFactory = Frostflake(generatorIdentifier: 987)

        for _ in 0 ..< 10_000 {
            let number: UInt64 = frostflakeFactory.generate()

            let encoded = number.base58

            if let decoded = UInt64(base58: encoded) {
//                print("\(number) == \(encoded) == \(decoded)")
                XCTAssertEqual(number, decoded)
                XCTAssertEqual(encoded, decoded.base58)
            }
        }
    }
}
