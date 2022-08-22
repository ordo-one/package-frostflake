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
        .executable(
            name: "frostflakeBenchmark",
            targets: ["Benchmark"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-system", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/ordo-one/package-concurrency-helpers", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting", from: Version("2.0.0"))
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
            name: "Benchmark",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SystemPackage", package: "swift-system"),
                "Frostflake",
            ]
        ),
        .target(name: "Frostflake",
                dependencies: [
                    .product(name: "ConcurrencyHelpers", package: "package-concurrency-helpers"),
                ],
                path: "Sources/Frostflake"),
        .testTarget(
            name: "FrostflakeTests",
            dependencies: ["SwiftFrostflake",
                           "Frostflake",
                           .product(name: "CwlPreconditionTesting", package: "CwlPreconditionTesting",
                                    .when(platforms: [.macOS])
                                   )
                          ]
        ),
        .testTarget(
            name: "FrostflakePerformanceTests",
            dependencies: ["Frostflake"],
            swiftSettings: [.unsafeFlags(["-O"])]
        )
    ]
)
