// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "package-frostflake",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "Frostflake",
            targets: ["Frostflake"]
        ),
        .executable(
            name: "flake",
            targets: ["FrostflakeUtility"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-atomics", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-system", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/ordo-one/package-datetime", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting", from: Version("2.0.0"))
    ],
    targets: [
        // Main library target
        .target(name: "Frostflake",
                dependencies: [
                    .product(name: "Atomics", package: "swift-atomics"),
                    .product(name: "DateTime", package: "package-datetime"),
                ],
                path: "Sources/Frostflake"),

        // Command line Frostflake generator
        .executableTarget(
            name: "FrostflakeUtility",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SystemPackage", package: "swift-system"),
                "Frostflake",
            ]
        ),

        // Benchmark targets
        .executableTarget(
            name: "Frostflake-Benchmark",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "BenchmarkPlugin", package: "package-benchmark"),
                "Frostflake",
            ],
            path: "Benchmarks/Benchmark"
        ),

        // Test targets
        .testTarget(
            name: "FrostflakeTests",
            dependencies: ["FrostflakeUtility",
                           "Frostflake",
                           .product(name: "CwlPreconditionTesting", package: "CwlPreconditionTesting",
                                    condition: .when(platforms: [.macOS]))]
        )
    ]
)
