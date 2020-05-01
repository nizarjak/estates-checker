// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "estates-checker",
    products: [
        .executable(
            name: "EstatesChecker",
            targets: ["App"]),
        .library(
            name: "ComposableArchitecture",
            targets: ["ComposableArchitecture"]),
        .library(
            name: "CLI",
            targets: ["CLI"]),
        .library(
            name: "EstatesProvider",
            targets: ["EstatesProvider"]),
        .library(
            name: "Notifications",
            targets: ["Notifications"]),
        .library(
            name: "Storage",
            targets: ["Storage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.5"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                "ComposableArchitecture",
                "CLI",
                "EstatesProvider",
                "Notifications",
                "Storage"
            ],
            path: "Sources/App"
        ),
        .target(
            name: "ComposableArchitecture",
            dependencies: [],
            path: "Sources/ComposableArchitecture"
        ),
        .target(
            name: "CLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "ComposableArchitecture",
                "Notifications",
                "Storage",
            ],
            path: "Sources/CLI"
        ),
        .target(
            name: "EstatesProvider",
            dependencies: [
            ],
            path: "Sources/EstatesProvider"
        ),
        .target(
            name: "Notifications",
            dependencies: [
                "ComposableArchitecture",
            ],
            path: "Sources/Notifications"
        ),
        .target(
            name: "Storage",
            dependencies: ["ComposableArchitecture"],
            path: "Sources/Storage"
        ),
    ]
)
