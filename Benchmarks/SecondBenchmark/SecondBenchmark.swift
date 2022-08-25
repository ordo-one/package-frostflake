import Benchmark
import Frostflake

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {

    Benchmark("Frostflake test",
              probes: [.cpu, .memory, .syscalls, .threads],
              isolation: true,
              minimumRuntime: 5000,
              disabled: false) {  benchmark in

        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))

        benchmark.measure {
            for _ in 0 ..< 1000_000 {
                let frostflake = frostflakeFactory.generate()
                let description = frostflake.frostflakeDescription()
                blackHole(description)
            }
        }
    }

    Benchmark("Frostflake simple") { benchmark in
        benchmark.measure {
            let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))
            for _ in 0 ..< 1000_000 {
                let frostflake = frostflakeFactory.generate()
                let description = frostflake.frostflakeDescription()
                blackHole(description)
            }
        }
    }
}
