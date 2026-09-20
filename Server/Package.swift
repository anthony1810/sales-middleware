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
        .library(
            name: "RatesCache",
            targets: ["RatesCache"]),
        .library(
            name: "RatesTransport",
            targets: ["RatesTransport"]),
    ],
    dependencies: [
        .package(path: "../RatesCore"),
        .package(path: "../HTTPClient"),
        .package(path: "../TestSupport"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "RatesUpstreamAPI",
            dependencies: [
                .product(name: "RatesCore", package: "RatesCore"),
                .product(name: "HTTPClient", package: "HTTPClient"),
            ],
            swiftSettings: swift6),
        .target(
            name: "RatesCache",
            dependencies: [
                .product(name: "RatesCore", package: "RatesCore")
            ],
            swiftSettings: swift6),
        .testTarget(
            name: "RatesCacheTests",
            dependencies: [
                "RatesCache",
                .product(name: "RatesCore", package: "RatesCore"),
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6),
        .target(
            name: "RatesTransport",
            dependencies: [
                .product(name: "RatesCore", package: "RatesCore"),
                .product(name: "Hummingbird", package: "hummingbird"),
            ],
            swiftSettings: swift6),
        .testTarget(
            name: "RatesTransportTests",
            dependencies: [
                "RatesTransport",
                .product(name: "RatesCore", package: "RatesCore"),
                .product(name: "HummingbirdTesting", package: "hummingbird"),
                .product(name: "TestSupport", package: "TestSupport"),
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
