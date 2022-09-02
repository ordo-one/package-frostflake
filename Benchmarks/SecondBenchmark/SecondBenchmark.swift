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

    Benchmark("Frostflake test",
              metrics: [.cpu, .mallocCountTotal, .syscalls, .threads],
              timeUnits: .automatic,
              isolation: true,
              warmup: false,
              desiredRuntime: 1500,
              desiredIterations: 3,
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
            for _ in 0 ..< 100 {
                let frostflake = frostflakeFactory.generate()
                let description = frostflake.frostflakeDescription()
                blackHole(description)

                // Generate some mallocs for testing
                for _ in 0..<100 {
                    let x = malloc(100)
                    blackHole(x)
                  //  free(x)
                }
                /*
                 var a = Array(repeating: "d", count: 1000_000)
                 var b = Array(repeating: "d", count: 1000_000)
                 //                var c = Array(repeating: "d", count: 1000_000)
                 //                var d = Array(repeating: "d", count: 1000_000)
                 b[0] = "dslkfjasdlfkjasdlfkjasldfjsaldkfasdflkj"
                 //               c[0] = "1"
                 //               d[0] = "sdf1"
                 blackHole(a+b) // +c+d)
                 a = []
                 b = a
                 blackHole(a+b) // +c+d)
                 b.append("asdflkjasdlfkjasdlfkjaslkdfsladkjfsldkfj")
                 blackHole(a+b) // +c+d)
                 a.append("asdflkjasdlfkjasdlfkjaslkdfsladkjfsldkfj")
                 blackHole(a+b) // +c+d)
                 //               c = a
                 //               d = a
                 */
            }
        }
    }

    Benchmark("Frostflake One Million+", metrics: [.wallClock], warmup: false, desiredIterations: 10) { benchmark in
        benchmark.measure {
            let z = malloc(2*1024*1024)
            blackHole(z)
           // free(z)
         //   free(z)
            let i = malloc(1*1024*1024)
            blackHole(i)
            free(i)
            for _ in 0 ..< 10 {
/*                let x = malloc(1024)
                blackHole(x)
                free(x)
                let y = malloc(1024)
                blackHole(y)
                free(y) */
                let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))

                for _ in 1 ..< 1 << sequenceNumberBits {
                    blackHole(frostflakeFactory.generate())
                }
            }
        }
    }
}
