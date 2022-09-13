import Frostflake

import BenchmarkSupport
@main extension BenchmarkRunner {}
@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {

    Benchmark("Frostflake descriptions") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))
        for _ in 0 ..< 100 {
            let frostflake = frostflakeFactory.generate()
            let description = frostflake.frostflakeDescription()
            blackHole(description)
        }
    }

    Benchmark("Frostflake One Million+",
              metrics: BenchmarkMetric.extended,
              scalingFactor: .mega,
              desiredIterations: 20) { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))

        for _ in 0 ..< benchmark.scalingFactor.rawValue {
            blackHole(frostflakeFactory.generate())
        }
    }
}
