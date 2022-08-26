import Benchmark
import Frostflake

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {

    Benchmark("Frostflake test",
              metrics: [.cpu, .memory, .syscalls, .threads],
              isolation: true,
              minimumRuntime: 100,
              disabled: false) {  benchmark in

        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))

        benchmark.measure {
            for _ in 1 ..< 1 << sequenceNumberBits {
                blackHole(frostflakeFactory.generate())
            }
        }
    }

    Benchmark("Frostflake simple", timeUnits: .milliseconds) { benchmark in

        benchmark.measure {
            let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))
            for _ in 0 ..< 100_000 {
                let frostflake = frostflakeFactory.generate()
                let description = frostflake.frostflakeDescription()
                blackHole(description)
            }
        }
    }
}
