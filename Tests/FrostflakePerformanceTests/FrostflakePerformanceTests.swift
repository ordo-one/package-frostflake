import Frostflake
import XCTest

final class FrostflakePerformanceTests: XCTestCase {
    private let sequenceNumberBits = 20

    #if canImport(Darwin)
        // Generate approximately 100M Frostflakes
        func testFrostflakePerformance() throws {
            measure(metrics: [XCTCPUMetric(), XCTClockMetric(), XCTMemoryMetric()]) {
                for generatorId in 0 ..< 100 {
                    let frostflakeGenerator = Frostflake(generatorIdentifier: UInt16(generatorId))

                    for _ in 1 ..< 1 << sequenceNumberBits {
                        blackHole(frostflakeGenerator.generatorFrostflakeIdentifier())
                    }
                }
            }
        }
    #endif
}
