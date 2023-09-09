// swift-tools-version:5.8
import PackageDescription

let swiftSettings: [SwiftSetting] = [.enableExperimentalFeature("StrictConcurrency")]

let package = Package(
    name: "chinchilla",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "Chinchilla", targets: ["Chinchilla"]),
    ],
    targets: [
        .target(name: "Chinchilla", swiftSettings: swiftSettings),
        .testTarget(
            name: "Unit",
            dependencies: [.target(name: "Chinchilla")],
            swiftSettings: swiftSettings
        ),
    ]
)
