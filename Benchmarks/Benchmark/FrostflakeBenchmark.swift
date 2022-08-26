// import ArgumentParser
import Benchmark
import Frostflake

let classIterationCount = 1000

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {
    //    print("Hello")
    // Once during runtime setup can be done before registering benchmarks
    let frostflake = Frostflake(generatorIdentifier: 0)
    Frostflake.setup(sharedGenerator: frostflake)

    Benchmark("Frostflake shared generator",
              metrics: [.cpu, .memory, .syscalls, .threads],
              isolation: true,
              minimumRuntime: 100,
              disabled: false) {  benchmark in
        benchmark.measure {
            for _ in 0 ..< 10 {
                        blackHole(Frostflake.generate())
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
