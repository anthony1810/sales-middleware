// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "RatesCore",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(
            name: "RatesCore",
            targets: ["RatesCore"]),
    ],
    targets: [
        .target(
            name: "RatesCore",
            swiftSettings: swift6),
        .testTarget(
            name: "RatesCoreTests",
            dependencies: ["RatesCore"],
            swiftSettings: swift6),
    ]
)
