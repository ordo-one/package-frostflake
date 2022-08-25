import Benchmark
import Frostflake

@_dynamicReplacement(for: benchmarks)
func registerBenchmarks() {

    Benchmark("Frostflake test",
              probes: [.cpu, .memory, .syscalls, .threads],
              isolation: true,
              minimumRuntime: 5000,
              disabled: false) {  benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: 1_000)

        benchmark.setupDone()

        for _ in 0 ..< 1000_000 {
            let frostflake = frostflakeFactory.generate()
            let description = frostflake.frostflakeDescription()
            blackHole(description)
        }

        benchmark.benchmarkDone() // implicit, but needed if we want cleanup after benchmark
    }

    Benchmark("Frostflake simple", disabled: true) { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: 1_000)
        for _ in 0 ..< 1000_000 {
            let frostflake = frostflakeFactory.generate()
            let description = frostflake.frostflakeDescription()
            blackHole(description)
        }
    }
}
