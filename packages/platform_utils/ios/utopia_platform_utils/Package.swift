// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "utopia_platform_utils",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "utopia-platform-utils", targets: ["utopia_platform_utils"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "utopia_platform_utils",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
