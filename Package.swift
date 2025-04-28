// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SwiftSSLPinning",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "SwiftSSLPinning",
            targets: ["SwiftSSLPinning"]),
    ],
    targets: [
        .target(
            name: "SwiftSSLPinning",
            dependencies: []),
        .testTarget(
            name: "SwiftSSLPinningTests",
            dependencies: ["SwiftSSLPinning"]),
    ]
) 