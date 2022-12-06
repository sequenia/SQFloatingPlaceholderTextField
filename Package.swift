// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SQFloatingPlaceholderTextField",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "SQFloatingPlaceholderTextField",
            targets: ["SQFloatingPlaceholderTextField"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SQFloatingPlaceholderTextField",
        ),
        .testTarget(
            name: "SQFloatingPlaceholderTextFieldTests",
            dependencies: ["SQFloatingPlaceholderTextField"]),
    ]
)
