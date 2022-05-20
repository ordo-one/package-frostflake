import Frostflake
import XCTest

final class FrostflakePerformanceTests: XCTestCase {
    private let sequenceNumberBits = 20

    func testFrostflakePerformance() throws {
        let metrics: [XCTMetric] = [XCTCPUMetric(), XCTClockMetric(), XCTMemoryMetric()]
        // Generate approximately 100M Frostflakes
        measure(metrics: metrics) {
            for generatorId in 0 ..< 100 {
                let frostflakeGenerator = Frostflake(generatorIdentifier: UInt16(generatorId))

                for _ in 1 ..< 1 << sequenceNumberBits {
                    blackHole(frostflakeGenerator.generatorFrostflakeIdentifier())
                }
            }
        }
    }
}
