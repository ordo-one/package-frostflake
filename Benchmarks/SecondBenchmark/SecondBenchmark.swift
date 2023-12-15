import Frostflake

import Benchmark

let benchmarks = {

    Benchmark("Frostflake descriptions") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))
        for _ in 0 ..< 100 {
            let frostflake = frostflakeFactory.generate()
            let description = frostflake.frostflakeDescription()
            Benchmark.blackHole(description)
        }
    }
    let config: Benchmark.Configuration = .init(metrics: BenchmarkMetric.extended, scalingFactor: .mega, maxDuration: .seconds(3))

    Benchmark("Frostflake One Million+", configuration: config) { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))

        for _ in benchmark.scaledIterations {
            Benchmark.blackHole(frostflakeFactory.generate())
        }
    }
}
