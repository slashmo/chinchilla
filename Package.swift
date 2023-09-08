// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "chinchilla",
    products: [
        .library(name: "Chinchilla", targets: ["Chinchilla"]),
    ],
    targets: [
        .target(name: "Chinchilla", swiftSettings: []),
    ]
)
