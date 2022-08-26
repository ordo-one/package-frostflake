// import ArgumentParser
import Benchmark
import Frostflake

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("Unsupported Platform")
#endif

let classIterationCount = 1000

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {
    print("Hello 1")
  fflush(nil)
    // Once during runtime setup can be done before registering benchmarks
    let frostflake = Frostflake(generatorIdentifier: 0)
    print("Hello 2")
    fflush(nil)
    Frostflake.setup(sharedGenerator: frostflake)
    print("Hello 3")
    fflush(nil)

    Benchmark("Frostflake shared generator",
              metrics: [.cpu, .memory, .syscalls, .threads],
              isolation: true,
              minimumRuntime: 100,
              disabled: false) {  benchmark in
        benchmark.measure {
            for _ in 0 ..< 10 {
                print("Hello 4")
                fflush(nil)
                        blackHole(Frostflake.generate())
                print("Hello 5")
                fflush(nil)
            }
        }
        /*
         benchmark.measure {
         for _ in 0 ..< classIterationCount {
         blackHole(Frostflake.generate())
         }
         }*/
    }

    Benchmark("Frostflake with locks") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...1000),
                                           concurrentAccess: true)

        benchmark.measure {
            for _ in 0 ..< classIterationCount {
                blackHole(frostflakeFactory.generate())
            }
        }
    }

    Benchmark("Frostflake without locks") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...1000),
                                           concurrentAccess: false)

        benchmark.measure {
            for _ in 0 ..< classIterationCount {
                blackHole(frostflakeFactory.generate())
            }
        }
    }

    Benchmark("Frostflake generate factories") { benchmark in

        benchmark.measure {
            for _ in 0 ..< classIterationCount {
                let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 0...1000),
                                                   concurrentAccess: true)
                blackHole(frostflakeFactory)
            }
        }
    }

}
