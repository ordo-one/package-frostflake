[![Swift version](https://img.shields.io/badge/Swift-5.6-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.6-orange?style=flat-square) [![Code complexity analysis](https://github.com/ordo-one/package-frostflake/actions/workflows/scc-code-complexity.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/scc-code-complexity.yml) [![Swift Linux build](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-linux-build.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-linux-build.yml) [![Swift macOS build](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-macos-build.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-macos-build.yml) [![codecov](https://codecov.io/gh/ordo-one/package-frostflake/branch/main/graph/badge.svg?token=ZHJ2bqnmhG)](https://codecov.io/gh/ordo-one/package-frostflake)
[![Swift lint](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-lint.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-lint.yml) [![Swift outdated dependencies](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-outdated-dependencies.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-outdated-dependencies.yml)
[![Swift address sanitizer Linux](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-address-sanitizer-linux.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-address-sanitizer-linux.yml) [![Swift address sanitizer macOS](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-address-sanitizer-macos.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-address-sanitizer-macos.yml) [![Swift thread sanitizer Linux](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-thread-sanitizer-linux.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-thread-sanitizer-linux.yml) [![Swift thread sanitizer macOS](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-thread-sanitizer-macos.yml/badge.svg)](https://github.com/ordo-one/package-frostflake/actions/workflows/swift-thread-sanitizer-macos.yml)

# Frostflake

High performance unique ID generator for Swift inspired by [Snowflake](https://blog.twitter.com/engineering/en_us/a/2010/announcing-snowflake)
with a few small tweaks aimed for a distributed system setup with a medium level of active entities (hundreds) that independently
should be able to generate unique identifiers.

It takes a slightly different approach to minimize generation overhead.

One key difference compared to Snowflake is that Frostflake uses a frozen point in time repeatedly
until running out of generation identifier for it, which avoids getting the current time for every 
id generated - it will update that frozen time point for every 1K generated identifiers, so for 
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

The `generatorIdentifier` must be uniquely in use at a given point in time, either it needs to be
set with a configuration file / persisted, or a global broker needs to assign it to components 
that needs flake generators at runtime such that the same identifier is not used concurrently.

```
import Frostflake

func testFrostflake() {
  let frostflakeFactory = Frostflake(generatorIdentifier: 1)
  let frostflake = frostflakeFactory.generate()
  let decription = frostflake.frostflakeDescription()
  print(decription)
}

```
