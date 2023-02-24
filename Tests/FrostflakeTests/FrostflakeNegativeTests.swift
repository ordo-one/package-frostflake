// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

#if os(OSX)

    @testable import Frostflake

    import CwlPreconditionTesting
    import Darwin
    import XCTest

    final class FrostflakeNegativeTests: XCTestCase {
        // This is negative test that should fail on precodition
        func testFrostflakeClassTooManyIdentifiersPerSecond() throws {
            let frostflakeFactory = Frostflake(generatorIdentifier: 0)
            let testStarted = currentSecondsSinceEpoch()
            var idGenerated = 0

            let exceptionBadInstruction: BadInstructionException? = catchBadInstruction {
                repeat {
                    for _ in Frostflake.allowedSequenceNumberRange {
                        blackHole(frostflakeFactory.generate())
                        blackHole(frostflakeFactory.generate())
                        idGenerated += 2
                    }
                } while currentSecondsSinceEpoch() - testStarted <= 1
            }
            if idGenerated < Frostflake.allowedSequenceNumberRange.count {
                throw XCTSkip("This host is pretty slow, only \(idGenerated) generated")
            }
            XCTAssert(exceptionBadInstruction != nil,
                      "precondition on too many FrostFlake IDs per second was not triggered")
        }
    }

#endif
