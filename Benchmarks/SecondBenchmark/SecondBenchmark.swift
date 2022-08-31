import Benchmark
import Frostflake

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {

    Benchmark("Frostflake test",
              metrics: [.cpu, .memory, .syscalls, .threads],
              timeUnits: .automatic,
              isolation: true,
              warmup: false,
              minimumRuntime: 1500,
              minimumIterations: 3,
              disabled: false) {  benchmark in

        benchmark.measure {
            for _ in 1 ..< 25 {
                let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))
                for _ in 1 ..< 1 << sequenceNumberBits {
                    blackHole(frostflakeFactory.generate())
                }
            }
        }
    }

    Benchmark("Frostflake descriptions", timeUnits: .automatic) { benchmark in
        benchmark.measure {
            let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))
            for _ in 0 ..< 1_000 {
                let frostflake = frostflakeFactory.generate()
                let description = frostflake.frostflakeDescription()
                blackHole(description)
            }
        }
    }

    Benchmark("Frostflake One Million+", metrics: [.wallClock], minimumIterations: 5) { benchmark in
        benchmark.measure {
            for _ in 0 ..< 100 {
                let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))

                for _ in 1 ..< 1 << sequenceNumberBits {
                    blackHole(frostflakeFactory.generate())
                }
            }
        }
    }
}
