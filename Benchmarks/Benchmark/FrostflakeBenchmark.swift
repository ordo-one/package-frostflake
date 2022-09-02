import Benchmark
import Frostflake
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

    Benchmark("Empty benchmark") { benchmark in
        benchmark.measure {
            for _ in 0..<5 {
                let z = malloc(1024*1024*1024)
                blackHole(z)
                free(z)
            }
            let z = malloc(1024*1024*1024)
            blackHole(z)
        }
    }

    Benchmark("Frostflake with locks") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...(1<<generatorIdentifierBits)-1),
                                           concurrentAccess: true)

        benchmark.measure {
            for _ in 0 ..< 1_000 {
                blackHole(frostflakeFactory.generate())
            }
        }
    }

    Benchmark("Frostflake without locks", desiredIterations: 1_000_000) { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...(1<<generatorIdentifierBits)-1),
                                           concurrentAccess: false)

        benchmark.measure {
            for _ in 0 ..< 1_000 {
                blackHole(frostflakeFactory.generate())
            }
        }
    }

    Benchmark("Frostflake generate factories") { benchmark in
        benchmark.measure {
            for _ in 0 ..< 1_000 {
                let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...(1<<generatorIdentifierBits)-1),
                                                   concurrentAccess: true)
                blackHole(frostflakeFactory)
            }
        }
    }

}
