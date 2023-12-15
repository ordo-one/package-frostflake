// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "package-frostflake",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "Frostflake",
            targets: ["Frostflake"]
        ),
        .executable(
            name: "flake",
            targets: ["SwiftFrostflake"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-system", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/ordo-one/package-concurrency-helpers", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.14.0")),
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting", from: Version("2.0.0"))
    ],
    targets: [
        // Command line Frostflake generator
        .executableTarget(
            name: "SwiftFrostflake",
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
                "Frostflake",
            ],
            path: "Benchmarks/Benchmark",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]

        ),

        .executableTarget(
            name: "Second-Benchmark",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "Benchmark", package: "package-benchmark"),
                "Frostflake",
            ],
            path: "Benchmarks/SecondBenchmark",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]

        ),

        // Main library target
        .target(name: "Frostflake",
                dependencies: [
                    .product(name: "ConcurrencyHelpers", package: "package-concurrency-helpers"),
                ],
                path: "Sources/Frostflake"),

        // Test targets
        .testTarget(
            name: "FrostflakeTests",
            dependencies: ["SwiftFrostflake",
                           "Frostflake",
                           .product(name: "CwlPreconditionTesting", package: "CwlPreconditionTesting",
                                    condition: .when(platforms: [.macOS]))]
        )
    ]
)
