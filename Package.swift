// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "estates-checker",
    products: [
        .executable(
            name: "EstatesChecker",
            targets: ["estates-checker"]),
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
            name: "Sreality",
            targets: ["Sreality"]),
        .library(
            name: "BezRealitky",
            targets: ["BezRealitky"]),
        .library(
            name: "Notifications",
            targets: ["Notifications"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.5"),
    ],
    targets: [
        .target(
            name: "estates-checker",
            dependencies: [
                "ComposableArchitecture",
                "CLI"
            ],
            path: "Sources/estates-checker"
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
                "Sreality",
                "BezRealitky"
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
            name: "Sreality",
            dependencies: [
                "ComposableArchitecture",
                "EstatesProvider"
            ],
            path: "Sources/Sreality"
        ),
        .target(
            name: "BezRealitky",
            dependencies: [
                "ComposableArchitecture",
                "EstatesProvider"
            ],
            path: "Sources/BezRealitky"
        ),
        .target(
            name: "Notifications",
            dependencies: [],
            path: "Sources/Notifications"
        )
    ]
)
