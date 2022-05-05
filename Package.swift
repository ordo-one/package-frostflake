// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-frostflake",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "Frostflake",
            targets: ["Frostflake"]
        ),
        .executable(
            name: "SwiftFrostflake",
            targets: ["SwiftFrostflake"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-system", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/ordo-one/swift-concurrency-helpers", .upToNextMajor(from: "0.0.1")),
    ],
    targets: [
        .executableTarget(
            name: "SwiftFrostflake",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "ConcurrencyHelpers", package: "swift-concurrency-helpers"),
                "Frostflake",
            ]
        ),
        .target(name: "Frostflake", path: "Sources/Frostflake"),
        .testTarget(
            name: "SwiftFrostflakeTests",
            dependencies: ["SwiftFrostflake",
                           "Frostflake"]
        ),
    ]
)
