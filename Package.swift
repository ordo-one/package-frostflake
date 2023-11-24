// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import class Foundation.ProcessInfo
import PackageDescription

let externalDependencies: [String: Range<Version>] = [
    "https://github.com/apple/swift-argument-parser": .upToNextMajor(from: "1.0.0"),
    "https://github.com/apple/swift-system": .upToNextMajor(from: "1.0.0"),
    "https://github.com/apple/swift-docc-plugin": .upToNextMajor(from: "1.0.0"),
    "https://github.com/mattgallagher/CwlPreconditionTesting": .upToNextMajor(from: "2.0.0")
]

let internalDependencies: [String: Range<Version>] = [
    "package-concurrency-helpers": .upToNextMajor(from: "4.0.0-alpha.2"),
    "package-datetime": .upToNextMajor(from: "2.0.0-alpha.1"),
]

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
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "Frostflake",
            type: .dynamic,
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
                dependencies: [
                    .product(name: "PackageConcurrencyHelpers", package: "package-concurrency-helpers"),
                    .product(name: "DateTime", package: "package-datetime"),
                ],
                path: "Sources/Frostflake",
                swiftSettings: [
                    .enableExperimentalFeature("AccessLevelOnImport")
                ]
            ),

        // Command line Frostflake generator
        .executableTarget(
            name: "FrostflakeUtility",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SystemPackage", package: "swift-system"),
                "Frostflake",
            ]
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
