// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SQFloatingPlaceholderTextField",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "SQFloatingPlaceholderTextField",
            targets: ["SQFloatingPlaceholderTextField"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SQFloatingPlaceholderTextField",
            exclude: ["LICENSE_Component", "README_Component"],
            resources: [.process("Resources")]),
        .testTarget(
            name: "SQFloatingPlaceholderTextFieldTests",
            dependencies: ["SQFloatingPlaceholderTextField"]),
    ]
)
