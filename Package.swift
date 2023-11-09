// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "L10NDynamicFont",
    platforms: [.macOS(.v14), .iOS(.v14), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "L10NDynamicFont",
            targets: ["L10NDynamicFont"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "L10NDynamicFont"),
        .testTarget(
            name: "L10NDynamicFontTests",
            dependencies: ["L10NDynamicFont"]),
    ]
)
