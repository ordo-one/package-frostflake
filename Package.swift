// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "package-frostflake",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "Frostflake",
            targets: ["Frostflake"]
        ),
        .executable(
            name: "flake",
            targets: ["SwiftFrostflake"]
        ),
/*        .executable(
            name: "frostflakeBenchmark",
            targets: ["Frostflake-Benchmark"]
        ), */
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-system", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/ordo-one/package-concurrency-helpers", .upToNextMajor(from: "0.0.1")),
        .package(path: "../package-benchmark")
    ],
    targets: [
        .executableTarget(
            name: "SwiftFrostflake",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SystemPackage", package: "swift-system"),
                "Frostflake",
            ]
        ),
        .executableTarget(
            name: "Frostflake-Benchmark",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
                "Frostflake",
            ],
            path: "Benchmarks/Benchmark"
        ),
        .executableTarget(
            name: "Second-Benchmark",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
                "Frostflake",
            ],
            path: "Benchmarks/SecondBenchmark"
        ),
        .target(name: "Frostflake",
                dependencies: [
                    .product(name: "ConcurrencyHelpers", package: "package-concurrency-helpers"),
                ],
                path: "Sources/Frostflake"),
        .testTarget(
            name: "FrostflakeTests",
            dependencies: ["SwiftFrostflake",
                           "Frostflake"]
        ),
        .testTarget(
            name: "FrostflakePerformanceTests",
            dependencies: ["Frostflake"],
            swiftSettings: [.unsafeFlags(["-O"])]
        )
    ]
)
