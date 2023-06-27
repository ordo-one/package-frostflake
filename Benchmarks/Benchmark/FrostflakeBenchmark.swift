// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import Atomics
import Benchmark
import DateTime
import Frostflake

let benchmarks = {
    var frostflakeFactory: Frostflake! // avoid locks optimizations

    // Once during runtime setup can be done before registering benchmarks
    Benchmark.defaultConfiguration = .init(warmupIterations: 5,
                                           scalingFactor: .mega,
                                           maxDuration: .seconds(2),
                                           maxIterations: Int(UInt16.max) - 5 - 1)

    Benchmark("Frostflake with locks") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(benchmark.currentIteration),
                                           forcedTimeRegenerationInterval: 0,
                                           concurrentAccess: true)

        benchmark.startMeasurement()
        for _ in benchmark.scaledIterations {
            Benchmark.blackHole(frostflakeFactory.generate())
        }
    }

    Benchmark("Frostflake without locks") { benchmark in
        frostflakeFactory = Frostflake(generatorIdentifier: UInt16(benchmark.currentIteration),
                                       concurrentAccess: false)

        benchmark.startMeasurement()
        for _ in benchmark.scaledIterations {
            Benchmark.blackHole(frostflakeFactory.generate())
        }
    }

    Benchmark("Frostflake descriptions",
              configuration: .init(scalingFactor: .kilo)) { benchmark in
        frostflakeFactory = Frostflake(generatorIdentifier: UInt16(benchmark.currentIteration))
        for _ in benchmark.scaledIterations {
            let frostflake = frostflakeFactory.generate()
            let description = frostflake.frostflakeDescription()
            Benchmark.blackHole(description)
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

    // Limited to max 1M or we'll hit the max threshold here...
    Benchmark("Frostflake shared generator (multitask)",
              configuration: .init(
                  warmupIterations: 0,
                  scalingFactor: .kilo,
                  maxIterations: .kilo(1)
              )) { benchmark in

        let ffIDs = await withTaskGroup(of: FrostflakeIdentifier.self) { group in
            var ids = [FrostflakeIdentifier]()
            for _ in benchmark.scaledIterations {
                group.addTask {
                    Frostflake.generate()
                }
            }
            // grab movies as their tasks complete, and append them to the `movies` array
            for await id in group {
                ids.append(id)
            }
            return ids
        }
        for id in ffIDs {
            Benchmark.blackHole(id)
        }
    }
}
