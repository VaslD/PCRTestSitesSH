// swift-tools-version:5.4
// This package requires at least Xcode 12.5

import PackageDescription

let package = Package(
    name: "Jason",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        // Standard Jason module.
        .library(name: "Jason", targets: ["Jason"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Jason")
    ]
)
