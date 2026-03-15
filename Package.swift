// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-version",
    products: [
        .library(
            name: "Version",
            targets: ["Version"]
        ),
    ],
    targets: [
        .target(
            name: "Version"
        ),
        .testTarget(
            name: "VersionTests",
            dependencies: ["Version"]
        ),
    ]
)
