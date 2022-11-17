// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import BenchmarkSupport
import Frostflake
@main extension BenchmarkRunner {}

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {
    // Once during runtime setup can be done before registering benchmarks

    Benchmark.defaultThroughputScalingFactor = .mega
    Benchmark.defaultDesiredDuration = .seconds(2)
    Benchmark.defaultWarmupIterations = 5
    Benchmark.defaultDesiredIterations = Int(UInt16.max) - Benchmark.defaultWarmupIterations - 1

    Benchmark("Frostflake with locks") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(benchmark.currentIteration),
                                           concurrentAccess: true)

        benchmark.startMeasurement()
        for _ in 0 ..< benchmark.throughputScalingFactor.rawValue {
            BenchmarkSupport.blackHole(frostflakeFactory.generate())
        }
    }

    Benchmark("Frostflake without locks") { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(benchmark.currentIteration),
                                           concurrentAccess: false)

        benchmark.startMeasurement()
        for _ in 0 ..< benchmark.throughputScalingFactor.rawValue {
            BenchmarkSupport.blackHole(frostflakeFactory.generate())
        }
    }

    Benchmark("Frostflake descriptions", throughputScalingFactor: .kilo) { benchmark in
        let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(benchmark.currentIteration))
        for _ in 0 ..< benchmark.throughputScalingFactor.rawValue {
            let frostflake = frostflakeFactory.generate()
            let description = frostflake.frostflakeDescription()
            BenchmarkSupport.blackHole(description)
        }
    }

    let frostflake = Frostflake(generatorIdentifier: 0)
    Frostflake.setup(sharedGenerator: frostflake)

    // Limited to max 1M or we'll hit the max threshold here...
    Benchmark("Frostflake shared generator",
              warmupIterations: 0,
              throughputScalingFactor: .kilo,
              desiredIterations: .kilo(1)) { benchmark in
        for _ in 0 ..< benchmark.throughputScalingFactor.rawValue {
            BenchmarkSupport.blackHole(Frostflake.generate())
        }
    }
}
