[![Swift version](https://img.shields.io/badge/Swift-5.7-orange)](https://img.shields.io/badge/Swift-5.7-orange) [![Swift Linux build](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-linux-build.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-linux-build.yml) [![Swift macOS build](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-macos-build.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-macos-build.yml) [![codecov](https://codecov.io/gh/ordo-one/package-frostflake/branch/main/graph/badge.svg?token=ZHJ2bqnmhG)](https://codecov.io/gh/ordo-one/package-frostflake)
[![Swift lint](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-lint.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-lint.yml) [![Swift outdated dependencies](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-outdated-dependencies.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-outdated-dependencies.yml)

# Frostflake

High performance unique ID generator for Swift inspired by [Snowflake](https://blog.twitter.com/engineering/en_us/a/2010/announcing-snowflake)
with a few small tweaks aimed for a distributed system setup with a medium level of active entities (hundreds) that independently
should be able to generate unique identifiers. 

It can produce ~125M unique identifiers per second on an M1 base machine and is half the size of an UUID.

It takes a slightly different approach to minimize generation overhead.

One key difference compared to Snowflake is that Frostflake uses a frozen point in time repeatedly
until running out of generation identifier for it, which avoids getting the current time for every 
id generated - it will update that frozen time point for every 1K generated identifiers (by default), so for 
medium-flow generation the timestamp will periodically be updated to keep somewhat of a temporal
sorting across services most of the time - with the aim that the unique identifier should be 
suitable as e.g. a database key.

# Adding dependencies
To add to your project:
```
dependencies: [
    .package(url: "https://github.com/ordo-one/package-frostflake", .upToNextMajor(from: "2.0.1")),
]
```

and then add the dependency to your target, e.g.:

```
.executableTarget(
  name: "MyExecutableTarget",
  dependencies: [
  .product(name: "Frostflake", package: "package-frostflake")
]),
```
# Usage

The `generatorIdentifier` must be uniquely in use at a given point in time, either it needs to 
be set with a configuration file / persisted, or a global broker needs to assign it to components 
that needs flake generators at runtime such that the same identifier is not used concurrently.

```swift
import Frostflake

func testFrostflake() {
  let frostflakeFactory = Frostflake(generatorIdentifier: 1)
  let frostflake = frostflakeFactory.generate()
  let decription = frostflake.frostflakeDescription()
  print(decription)
}
```

There's also an optional shared class generator (which gives approx. 1/2 the performance):
```swift
Frostflake.setup(generatorIdentifier: 1) // Must always be set up once, globally shared
let frostflake1 =  FrostflakeIdentifier()
let frostflake2 =  FrostflakeIdentifier()
// Or optionally:
let frostflake3 =  Frostflake.generate()
let frostflake4 =  Frostflake.generate()
```
# Implementation notes
The Frostflake is a 64-bit value just like Snowflake, but the bit allocation differs a little bit. 

Frostflake by default allocates 32 bits for the timestamp (~136 years span), 21 bits for the sequence
number (allowing for up to 2.097.152 identifiers per second for a given generator) and 11 bits for the 
generator identifier (allowing for up to 2.048 unique workers/nodes in a system).

A possible future direction would be to allow for allocation of the bits between the sequence identifier
and generator identifier up to the user to more easily allow for different use cases - as long as this
would be reallocated during a service window (which just needs to be longer than the clock difference
between the two nodes in the cluster being most out of sync) the timestamp portion will continue to 
ensure uniqeness.

# Caveats

## Notes on clock synchronization requirements
It's expected that a host should have NTP enabled and not reset the clock with jumps during operation
(typical NTP usage would slowly skew the clock and shouldn't have any problems, but something to be aware of).
Different machines relative synchronized time is immaterial as the generatorIdentifier uniquely identifies
various producers of identifiers if set properly.

## Notes on maximum identifier generation rate
By default there's a maximum of ~2M generated identifiers per second per generatorIdentifier sustained - if this would
be exceeded we'll abort. That gives ~477ns per identifier - which for the designed purposes is far more than
ever would be used - but if you have a use case with a really high-volume generation, you can possibly reallocate
the big assignment by adjusting the split between generatorIdentifier and sequenceNumbers to cate for that too.

# Benchmarks

Can be run with `swift package benchmark`.

```
> swift package benchmark
Building for debugging...
Build complete! (0.22s)
Building targets in release mode for benchmark run...
Build complete! Running benchmarks...

Benchmark results
============================================================================================================================

Host 'ice.local' with 20 'arm64' processors with 128 GB memory, running:
Darwin Kernel Version 22.1.0: Sun Oct  9 20:15:09 PDT 2022; root:xnu-8792.41.9~2/RELEASE_ARM64_T6000

Frostflake-Benchmark
============================================================================================================================

Frostflake descriptions
╒══════════════════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                                   │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞══════════════════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Malloc (total)                           │    1003 │    1003 │    1003 │    1004 │    1004 │    1004 │    1004 │    2152 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Memory (resident peak) (K)               │    9142 │    9208 │    9208 │    9208 │    9208 │    9208 │    9208 │    2152 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (scaled / s) (K)              │    1111 │    1089 │    1076 │    1068 │    1058 │     989 │     849 │    2152 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (total CPU) (μs)                    │     901 │     919 │     930 │     936 │     945 │     975 │    1149 │    2152 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (μs)                   │     900 │     918 │     929 │     936 │     945 │    1011 │    1177 │    2152 │
╘══════════════════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Frostflake shared generator
╒══════════════════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                                   │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞══════════════════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Malloc (total)                           │       0 │       0 │       0 │       0 │       0 │       0 │       0 │    1000 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Memory (resident peak) (K)               │    9716 │    9716 │    9716 │    9716 │    9716 │    9716 │    9716 │    1000 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (scaled / s) (M)              │      61 │      61 │      60 │      60 │      60 │      30 │      24 │    1000 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (total CPU) (μs)                    │      17 │      17 │      17 │      17 │      18 │      34 │      42 │    1000 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (μs)                   │      16 │      17 │      17 │      17 │      17 │      33 │      41 │    1000 │
╘══════════════════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Frostflake with locks
╒══════════════════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                                   │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞══════════════════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Malloc (total)                           │       0 │       0 │       0 │       0 │       0 │       0 │       0 │     249 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Memory (resident peak) (K)               │    7750 │    7766 │    7766 │    7766 │    7766 │    7766 │    7766 │     249 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (scaled / s) (M)              │     127 │     125 │     125 │     124 │     124 │     118 │     116 │     249 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (total CPU) (μs)                    │    7883 │    8008 │    8030 │    8055 │    8083 │    8506 │    8592 │     249 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (μs)                   │    7883 │    8010 │    8030 │    8056 │    8086 │    8505 │    8591 │     249 │
╘══════════════════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Frostflake without locks
╒══════════════════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                                   │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞══════════════════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Malloc (total)                           │       0 │       0 │       0 │       0 │       0 │       0 │       0 │    1229 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Memory (resident peak) (K)               │    8634 │    8634 │    8634 │    8634 │    8634 │    8634 │    8634 │    1229 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (scaled / s) (M)              │     630 │     619 │     615 │     611 │     607 │     588 │     563 │    1229 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (total CPU) (μs)                    │    1589 │    1615 │    1626 │    1637 │    1648 │    1696 │    1765 │    1229 │
├──────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (μs)                   │    1588 │    1614 │    1626 │    1637 │    1648 │    1700 │    1775 │    1229 │
╘══════════════════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛
```
