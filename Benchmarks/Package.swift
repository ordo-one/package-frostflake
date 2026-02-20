// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/ordo-one/package-benchmark.git", from: "1.13.0")
    ],
    targets: [
        .executableTarget(
            name: "FrostflakeBenchmark",
            dependencies: [
                .product(name: "Frostflake", package: "package-frostflake"),
                .product(name: "Benchmark", package: "package-benchmark")
            ],
            path: "Benchmarks/Frostflake",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        )
    ]
)
