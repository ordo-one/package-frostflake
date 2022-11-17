[![Swift version](https://img.shields.io/badge/Swift-5.7-orange)](https://img.shields.io/badge/Swift-5.7-orange) [![Swift Linux build](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-linux-build.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-linux-build.yml) [![Swift macOS build](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-macos-build.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-macos-build.yml) [![codecov](https://codecov.io/gh/ordo-one/package-frostflake/branch/main/graph/badge.svg?token=ZHJ2bqnmhG)](https://codecov.io/gh/ordo-one/package-frostflake)
[![Swift lint](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-lint.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-lint.yml) [![Swift outdated dependencies](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-outdated-dependencies.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-outdated-dependencies.yml)

# Frostflake

High performance unique ID generator for Swift inspired by [Snowflake](https://blog.twitter.com/engineering/en_us/a/2010/announcing-snowflake)
with a few small tweaks aimed for a distributed system setup with a medium level of active entities (hundreds) that independently
should be able to generate unique identifiers. It can produce ~125M unique identifiers per second on an M1 base machine.

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
    .package(url: "https://github.com/ordo-one/package-frostflake", .upToNextMajor(from: "0.0.1")),
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
Frostflake.setup(generatorIdentifier: 1)
let frostflake1 =  Frostflake.generate()
let frostflake2 =  Frostflake.generate()
```

## Notes on clock synchronization requirements
It's expected that a host should have NTP enabled and not reset the clock with jumps during operation
(typical NTP usage would slowly skew the clock and shouldn't have any problems, but something to be aware of).
Different machines relative synchronized time is immaterial as the generatorIdentifier uniquely identifies
various producers of identifiers if set properly.

