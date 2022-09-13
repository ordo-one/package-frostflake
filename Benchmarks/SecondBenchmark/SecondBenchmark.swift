import Benchmark
import Frostflake
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("Unsupported Platform")
#endif

import BenchmarkSupport
@main extension BenchmarkRunner {}

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {

    Benchmark("Frostflake test",
              metrics: BenchmarkMetric.extended,
              timeUnits: .automatic,
              isolation: true,
              warmup: false,
              desiredDuration: .milliseconds(150),
              desiredIterations: 30,
              disabled: false) {  benchmark in
        for _ in 1 ..< 15 {
            let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))
            for _ in 1 ..< 1 << sequenceNumberBits {
                blackHole(frostflakeFactory.generate())
            }
        }
 }

    Benchmark("Frostflake descriptions") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))
        for _ in 0 ..< 100 {
            let frostflake = frostflakeFactory.generate()
            let description = frostflake.frostflakeDescription()
            blackHole(description)

            // Generate some mallocs for testing
  /*          for _ in 0..<100 {
                let x = malloc(100)
                blackHole(x)
              //  free(x)
            } */
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

    Benchmark("Frostflake One Million+", metrics: [.wallClock, .throughput], scalingFactor: .mega, desiredIterations: 10) { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16.random(in: 1...4000))

        for _ in 0 ..< benchmark.scalingFactor.rawValue {
            blackHole(frostflakeFactory.generate())
        }
    }
}
