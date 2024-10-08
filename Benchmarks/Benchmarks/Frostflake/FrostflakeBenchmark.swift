// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import Benchmark
import Frostflake

let benchmarks = {
    // Once during runtime setup can be done before registering benchmarks
    Benchmark.defaultConfiguration = .init(warmupIterations: 5,
                                           scalingFactor: .mega,
                                           maxDuration: .seconds(2),
                                           maxIterations: Int(UInt16.max) - 5 - 1)

    Benchmark("Frostflake with locks") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(benchmark.currentIteration),
                                           concurrentAccess: true)

        benchmark.startMeasurement()
        for _ in benchmark.scaledIterations {
            Benchmark.blackHole(frostflakeFactory.generate())
        }
    }

    Benchmark("Frostflake without locks") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(benchmark.currentIteration),
                                           concurrentAccess: false)

        benchmark.startMeasurement()
        for _ in benchmark.scaledIterations {
            Benchmark.blackHole(frostflakeFactory.generate())
        }
    }

    Benchmark("Frostflake descriptions",
              configuration: .init(scalingFactor: .kilo)) { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(benchmark.currentIteration))
        for _ in benchmark.scaledIterations {
            let frostflake = frostflakeFactory.generate()
            Benchmark.blackHole(frostflake.debugDescription)
        }
    }

    let frostflake = Frostflake(generatorIdentifier: 0)
    Frostflake.setup(sharedGenerator: frostflake)

    // Limited to max 1M or we'll hit the max threshold here...
    Benchmark("Frostflake shared generator",
              configuration: .init(
                  warmupIterations: 0,
                  scalingFactor: .kilo,
                  maxIterations: .kilo(1)
              )) { benchmark in
        for _ in benchmark.scaledIterations {
            Benchmark.blackHole(Frostflake.generate())
        }
    }

    Benchmark("Frostflake shared generator with FrostflakeIdentifier() convenience",
              configuration: .init(
                  warmupIterations: 0,
                  scalingFactor: .kilo,
                  maxIterations: .kilo(1)
              )) { benchmark in
        for _ in benchmark.scaledIterations {
            Benchmark.blackHole(FrostflakeIdentifier())
        }
    }
}
