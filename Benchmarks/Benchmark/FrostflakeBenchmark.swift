import Frostflake
import BenchmarkSupport
@main extension BenchmarkRunner {}

// Pull in system for malloc testing
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("Unsupported Platform")
#endif

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {

    // Once during runtime setup can be done before registering benchmarks


    Benchmark("Minimal benchmark", metrics: [.wallClock]) { benchmark in
    }


    Benchmark("Custom benchmark", metrics: [.custom("testMetric")]) { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...(1<<generatorIdentifierBits)-1),
                                           concurrentAccess: true)

        benchmark.measurement(.custom("testMetric"), 987347711)
            for _ in 0 ..< benchmark.scalingFactor.rawValue {
            blackHole(frostflakeFactory.generate())
        }

    }

    Benchmark("Scaling factor benchmark", scalingFactor: .mega) { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...(1<<generatorIdentifierBits)-1),
                                           concurrentAccess: true)

        benchmark.startMeasurement()
        for _ in 0 ..< benchmark.scalingFactor.rawValue {
            blackHole(frostflakeFactory.generate())
        }
    }


    Benchmark("Frostflake with locks") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...(1<<generatorIdentifierBits)-1),
                                           concurrentAccess: true)

        benchmark.startMeasurement()
        for _ in 0 ..< 1_000 {
            blackHole(frostflakeFactory.generate())
        }
    }

    Benchmark("Frostflake without locks", desiredIterations: 1_000_000) { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...(1<<generatorIdentifierBits)-1),
                                           concurrentAccess: false)

        benchmark.startMeasurement()
        for _ in 0 ..< 1_000 {
            blackHole(frostflakeFactory.generate())
        }
    }

    Benchmark("Frostflake generate factories", scalingFactor: .kilo) { benchmark in
        for _ in 0 ..< benchmark.scalingFactor.rawValue {
            let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...(1<<generatorIdentifierBits)-1),
                                               concurrentAccess: true)
            blackHole(frostflakeFactory)
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
