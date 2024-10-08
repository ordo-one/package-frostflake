// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import class Foundation.ProcessInfo
import PackageDescription

let externalDependencies: [String: Range<Version>] = [
    "https://github.com/apple/swift-argument-parser": .upToNextMajor(from: "1.0.0"),
    "https://github.com/apple/swift-system": .upToNextMajor(from: "1.0.0"),
    "https://github.com/apple/swift-docc-plugin": .upToNextMajor(from: "1.0.0")
]

let internalDependencies: [String: Range<Version>] = [:]

func makeDependencies() -> [Package.Dependency] {
    var dependencies: [Package.Dependency] = []
    dependencies.reserveCapacity(externalDependencies.count + internalDependencies.count)

    for extDep in externalDependencies {
        dependencies.append(.package(url: extDep.key, extDep.value))
    }

    let localPath = ProcessInfo.processInfo.environment["LOCAL_PACKAGES_DIR"]

    for intDep in internalDependencies {
        if let localPath {
            dependencies.append(.package(name: "\(intDep.key)", path: "\(localPath)/\(intDep.key)"))
        } else {
            dependencies.append(.package(url: "https://github.com/ordo-one/\(intDep.key)", intDep.value))
        }
    }
    return dependencies
}

let package = Package(
    name: "package-frostflake",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
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
    dependencies: makeDependencies(),
    targets: [
        // Main library target
        .target(name: "Frostflake",
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
        .testTarget(
            name: "FrostflakeTests",
            dependencies: [
                "FrostflakeUtility", "Frostflake"
            ]
        )
    ]
)
