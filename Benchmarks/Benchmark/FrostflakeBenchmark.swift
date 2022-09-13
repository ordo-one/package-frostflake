import Frostflake
import BenchmarkSupport
@main extension BenchmarkRunner {}

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {

    // Once during runtime setup can be done before registering benchmarks

    Benchmark("Frostflake with locks", scalingFactor: .kilo, desiredDuration: .seconds(1)) { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...(1<<generatorIdentifierBits)-1),
                                           concurrentAccess: true)

        benchmark.startMeasurement()
        for _ in 0 ..< benchmark.scalingFactor.rawValue {
            blackHole(frostflakeFactory.generate())
        }
    }

    Benchmark("Frostflake without locks", scalingFactor: .kilo, desiredDuration: .seconds(1)) { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...(1<<generatorIdentifierBits)-1),
                                           concurrentAccess: false)

        benchmark.startMeasurement()
        for _ in 0 ..< benchmark.scalingFactor.rawValue {
            blackHole(frostflakeFactory.generate())
        }
    }

    /* Can't run this benchmark due to max number of frostflakes per second!
     let frostflake = Frostflake(generatorIdentifier: 0)
     Frostflake.setup(sharedGenerator: frostflake)


     Benchmark("Frostflake shared generator",
     metrics: [.cpu, .memory, .syscalls, .threads],
     isolation: true,
     minimumRuntime: 100,
     disabled: false) {  benchmark in
     benchmark.measure {
     for _ in 0 ..< 1_000_000 {
     blackHole(Frostflake.generate())
     }
     }
     }

     */
}
