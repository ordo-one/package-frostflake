// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import class Foundation.ProcessInfo
import PackageDescription

let package = Package(
    name: "package-frostflake",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "Frostflake",
            type: .dynamic,
            targets: ["Frostflake"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-datetime", from: "2.0.0-alpha.1"),
    ],
    targets: [
        // Main library target
        .target(
            name: "Frostflake",
                dependencies: [
                    .product(name: "DateTime", package: "package-datetime")
                ],
                path: "Sources/Frostflake"
        )
    ]
)
