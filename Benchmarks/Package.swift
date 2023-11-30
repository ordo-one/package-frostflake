// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/ordo-one/package-benchmark.git", from: "1.13.0"),
        //.package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        //.package(url: "https://github.com/apple/swift-system", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "FrostflakeBenchmark",
            dependencies: [
                .product(name: "Frostflake", package: "package-frostflake"),
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "BenchmarkPlugin", package: "package-benchmark"),
                //.product(name: "ArgumentParser", package: "swift-argument-parser"),
                //.product(name: "SystemPackage", package: "swift-system"),
            ],
            path: "Benchmarks/Frostflake"
        )
    ]
)
