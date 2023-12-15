import Frostflake
import Benchmark

let benchmarks = {

    // Once during runtime setup can be done before registering benchmarks
    Benchmark.defaultConfiguration = .init(scalingFactor: .kilo, maxDuration: .seconds(3))
    Benchmark("Frostflake with locks") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...(1<<generatorIdentifierBits)-1),
                                           concurrentAccess: true)

        benchmark.startMeasurement()
        for _ in benchmark.scaledIterations {
            Benchmark.blackHole(frostflakeFactory.generate())
        }
    }

    Benchmark("Frostflake without locks") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...(1<<generatorIdentifierBits)-1),
                                           concurrentAccess: false)

        benchmark.startMeasurement()
        for _ in benchmark.scaledIterations {
            Benchmark.blackHole(frostflakeFactory.generate())
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
