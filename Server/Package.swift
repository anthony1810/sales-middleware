// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "Server",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(
            name: "RatesUpstreamAPI",
            targets: ["RatesUpstreamAPI"]),
    ],
    dependencies: [
        .package(path: "../RatesCore"),
        .package(path: "../HTTPClient"),
        .package(path: "../TestSupport"),
    ],
    targets: [
        .target(
            name: "RatesUpstreamAPI",
            dependencies: [
                .product(name: "RatesCore", package: "RatesCore"),
                .product(name: "HTTPClient", package: "HTTPClient"),
            ],
            swiftSettings: swift6),
        .testTarget(
            name: "RatesUpstreamAPITests",
            dependencies: [
                "RatesUpstreamAPI",
                .product(name: "RatesCore", package: "RatesCore"),
                .product(name: "HTTPClient", package: "HTTPClient"),
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
    ]
)
