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
                    for _ in 1 ... 10_000 {
                        blackHole(frostflakeFactory.generate())
                    }
                    idGenerated += 10_000
                } while currentSecondsSinceEpoch() - testStarted <= 1
            }
            if idGenerated < 1_000_000 {
                throw XCTSkip("This host is pretty slow, only \(idGenerated) generated for 1 second")
            }
            XCTAssert(exceptionBadInstruction != nil,
                      "precondition on too many FrostFlake IDs per second was not triggered")
        }
    }
#endif
