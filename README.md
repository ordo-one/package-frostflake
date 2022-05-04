[![Swift version](https://img.shields.io/badge/Swift-5.6-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.6-orange?style=flat-square) [![Code complexity analysis](https://github.com/ordo-one/swift-frostflake/actions/workflows/scc-code-complexity.yml/badge.svg)](https://github.com/ordo-one/swift-frostflake/actions/workflows/scc-code-complexity.yml) [![Swift Linux build](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-linux-build.yml/badge.svg)](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-linux-build.yml) [![Swift macOS build](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-macos-build.yml/badge.svg)](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-macos-build.yml) [![codecov](https://codecov.io/gh/ordo-one/swift-frostflake/branch/main/graph/badge.svg?token=ZHJ2bqnmhG)](https://codecov.io/gh/ordo-one/swift-frostflake)
[![Swift lint](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-lint.yml/badge.svg)](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-lint.yml) [![Swift outdated dependencies](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-outdated-dependencies.yml/badge.svg)](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-outdated-dependencies.yml)
[![Swift address sanitizer Linux](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-address-sanitizer-linux.yml/badge.svg)](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-address-sanitizer-linux.yml) [![Swift address sanitizer macOS](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-address-sanitizer-macos.yml/badge.svg)](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-address-sanitizer-macos.yml) [![Swift thread sanitizer Linux](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-thread-sanitizer-linux.yml/badge.svg)](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-thread-sanitizer-linux.yml) [![Swift thread sanitizer macOS](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-thread-sanitizer-macos.yml/badge.svg)](https://github.com/ordo-one/swift-frostflake/actions/workflows/swift-thread-sanitizer-macos.yml)

# swift-frostflake

High performance unique ID generator for Swift inspired by [Snowflake](https://blog.twitter.com/engineering/en_us/a/2010/announcing-snowflake)
which is aimed for a distributed system setup with a medium level of active entities (hundreds) that independently
should be able to generate unique identifiers.

It takes a slightly different approach to minimize generation overhead while still keeping the trait 
of being _roughly sorted_ and allowing for distributed generation.

One key difference compared to Snowflake is that Frostflake can use a frozen point in time repeatedly
until running out of keyspace for it, which avoid getting the current time for every id generated.

Optionally Frostflake can get the point in time from the client generating the ID, for use cases
when a timestamp was generated external to Frostflake anyway, see the API documentation for details.

The main point with those two optional approaches is to not have to generate a timestamp for each 
id, while still keeping things time sorted within the span of each new point in time by help
of the sequence number - such that the identifier will be suitable as e.g. a database key.

Worth noting is that when using a frozen point in time, the time sorting characteristic will
be temporally local per producer only.

