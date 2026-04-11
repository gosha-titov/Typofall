// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Typofall",
    products: [
        .library(
            name: "Typofall",
            targets: ["Typofall"]
        ),
    ],
    targets: [
        .target(
            name: "Typofall",
            path: "Sources"
        ),
        .testTarget(
            name: "TypofallTests",
            dependencies: ["Typofall"],
            path: "Tests"
        ),
    ]
)
