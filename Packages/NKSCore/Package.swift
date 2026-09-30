// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NKSCore",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "NKSCore",
            targets: ["NKSCore"]
        ),
        .executable(
            name: "nks-dump",
            targets: ["NKSDump"]
        )
    ],
    targets: [
        .target(
            name: "NKSCore"
        ),
        .executableTarget(
            name: "NKSDump",
            dependencies: ["NKSCore"]
        ),
        .testTarget(
            name: "NKSCoreTests",
            dependencies: ["NKSCore"]
        ),
    ]
)
