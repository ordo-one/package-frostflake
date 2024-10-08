[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fordo-one%2Fpackage-frostflake%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ordo-one/package-frostflake) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fordo-one%2Fpackage-frostflake%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ordo-one/package-frostflake)

[![Swift Linux build](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-linux-build.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-linux-build.yml) [![Swift macOS build](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-macos-build.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-macos-build.yml) [![codecov](https://codecov.io/gh/ordo-one/package-frostflake/branch/main/graph/badge.svg?token=ZHJ2bqnmhG)](https://codecov.io/gh/ordo-one/package-frostflake)

# Frostflake

High performance unique ID generator for Swift inspired by [Snowflake](https://blog.twitter.com/engineering/en_us/a/2010/announcing-snowflake)
with a few small tweaks aimed for a distributed system setup with a medium level of active entities (hundreds) that independently
should be able to generate unique identifiers. 

It can produce ~115M unique identifiers per second on an M1 base machine and is half the size of an UUID.

It takes a slightly different approach to minimize generation overhead.

One key difference compared to Snowflake is that Frostflake uses a frozen point in time repeatedly
until running out of generation identifier for it, which avoids getting the current time for every 
id generated - it will update that frozen time point for every 1K generated identifiers (by default), so for 
medium-flow generation the timestamp will periodically be updated to keep somewhat of a temporal
sorting across services most of the time - with the aim that the unique identifier should be 
suitable as e.g. a database key.

The default output of a FrostflakeIdentifier is a base58 string for easier readability for humans, but
the UInt64 raw value is also accessible.

# Adding dependencies
To add to your project:
```
dependencies: [
    .package(url: "https://github.com/ordo-one/package-frostflake", .upToNextMajor(from: "6.0.0")),
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
  let decription = frostflake.debugDescription()
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

# Command line tool `flake`

### Generate a new frostflake identifier from command line (provides base58 representation)
```bash
> swift run flake
JERHwh5PXjL
```

### Decode a frostflake identifier
```bash
> swift run flake --identifier JERHwh5PXjL
Frostflake JERHwh5PXjL decoded:
JERHwh5PXjL 7423342004626526207 (2024-10-08 09:58:17 UTC, sequenceNumber:1, generatorIdentifier:2047)
> swift run flake --identifier 7423342004626526207
Frostflake JERHwh5PXjL decoded:
JERHwh5PXjL 7423342004626526207 (2024-10-08 09:58:17 UTC, sequenceNumber:1, generatorIdentifier:2047)
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
the big assignment by adjusting the split between generatorIdentifier and sequenceNumbers to cater for that too.

# Benchmarks

Can be run with `swift package benchmark`.

```
> swift package benchmark
...
==================
Running Benchmarks
==================

100% [------------------------------------------------------------] ETA: 00:00:00 | FrostflakeBenchmark:Frostflake descriptions
100% [------------------------------------------------------------] ETA: 00:00:00 | FrostflakeBenchmark:Frostflake shared generator
100% [------------------------------------------------------------] ETA: 00:00:00 | FrostflakeBenchmark:Frostflake shared generator with FrostflakeIdentifier() convenience
100% [------------------------------------------------------------] ETA: 00:00:00 | FrostflakeBenchmark:Frostflake with locks
100% [------------------------------------------------------------] ETA: 00:00:00 | FrostflakeBenchmark:Frostflake without locks

=====================================================================================================
Baseline 'Current_run'
=====================================================================================================

Host 'ice.local' with 20 'arm64' processors with 128 GB memory, running:
Darwin Kernel Version 24.0.0: Mon Aug 12 20:51:54 PDT 2024; root:xnu-11215.1.10~2/RELEASE_ARM64_T6000

===================
FrostflakeBenchmark
===================

Frostflake descriptions
╒═══════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                        │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞═══════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Instructions (K) *            │      36 │      36 │      36 │      36 │      36 │      37 │      37 │     928 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Malloc (total) *              │      30 │      30 │      30 │      30 │      30 │      30 │      30 │     928 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Memory (resident peak) (K)    │    9519 │    9871 │    9871 │    9880 │    9880 │    9880 │    9880 │     928 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (# / s) (K)        │     479 │     477 │     476 │     472 │     460 │     443 │     434 │     928 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (total CPU) (ns) *       │    2092 │    2101 │    2107 │    2122 │    2177 │    2253 │    2286 │     928 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (ns) *      │    2090 │    2099 │    2103 │    2120 │    2173 │    2261 │    2306 │     928 │
╘═══════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Frostflake shared generator
╒═══════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                        │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞═══════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Instructions *                │     245 │     245 │     245 │     245 │     245 │     249 │     254 │    1000 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Malloc (total) *              │       0 │       0 │       0 │       0 │       0 │       0 │       0 │    1000 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Memory (resident peak) (K)    │    9322 │    9740 │    9740 │    9748 │    9748 │    9748 │    9748 │    1000 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (# / s) (M)        │      63 │      63 │      63 │      61 │      61 │      49 │      36 │    1000 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (total CPU) (ns) *       │      18 │      18 │      18 │      18 │      19 │      22 │      30 │    1000 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (ns) *      │      16 │      16 │      16 │      16 │      16 │      20 │      28 │    1000 │
╘═══════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Frostflake shared generator with FrostflakeIdentifier() convenience
╒═══════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                        │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞═══════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Instructions *                │     245 │     245 │     245 │     245 │     245 │     245 │     260 │    1000 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Malloc (total) *              │       0 │       0 │       0 │       0 │       0 │       0 │       0 │    1000 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Memory (resident peak) (K)    │    9339 │    9757 │    9757 │    9765 │    9765 │    9765 │    9765 │    1000 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (# / s) (M)        │      64 │      63 │      63 │      63 │      62 │      58 │      41 │    1000 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (total CPU) (ns) *       │      18 │      18 │      18 │      18 │      18 │      20 │      27 │    1000 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (ns) *      │      16 │      16 │      16 │      16 │      16 │      17 │      24 │    1000 │
╘═══════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Frostflake with locks
╒═══════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                        │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞═══════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Instructions *                │     198 │     198 │     198 │     198 │     198 │     198 │     198 │     169 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Malloc (total) *              │       0 │       0 │       0 │       0 │       0 │       0 │       0 │     169 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Memory (resident peak) (K)    │    9421 │    9806 │    9822 │    9830 │    9830 │    9830 │    9830 │     169 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (# / s) (M)        │      86 │      85 │      85 │      85 │      83 │      82 │      82 │     169 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (total CPU) (ns) *       │      12 │      12 │      12 │      12 │      12 │      12 │      12 │     169 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (ns) *      │      12 │      12 │      12 │      12 │      12 │      12 │      12 │     169 │
╘═══════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Frostflake without locks
╒═══════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                        │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞═══════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Instructions *                │     175 │     175 │     175 │     175 │     175 │     175 │     175 │     226 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Malloc (total) *              │       0 │       0 │       0 │       0 │       0 │       0 │       0 │     226 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Memory (resident peak) (K)    │    9421 │    9822 │    9822 │    9830 │    9830 │    9830 │    9830 │     226 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (# / s) (M)        │     115 │     115 │     114 │     114 │     111 │     109 │     107 │     226 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (total CPU) (ns) *       │       9 │       9 │       9 │       9 │       9 │       9 │       9 │     226 │
├───────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (ns) *      │       9 │       9 │       9 │       9 │       9 │       9 │       9 │     226 │
╘═══════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛
```
