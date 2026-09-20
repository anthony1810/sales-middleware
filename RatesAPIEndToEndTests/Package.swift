// swift-tools-version: 6.0
import PackageDescription

let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "RatesAPIEndToEndTests",
    platforms: [.macOS(.v14), .iOS(.v17)],
    dependencies: [
        .package(path: "../RatesCore"),
        .package(path: "../Server"),
        .package(path: "../HTTPClient"),
        .package(path: "../TestSupport"),
    ],
    targets: [
        .testTarget(
            name: "RatesAPIEndToEndTests",
            dependencies: [
                .product(name: "RatesCore", package: "RatesCore"),
                .product(name: "RatesUpstreamAPI", package: "Server"),
                .product(name: "RatesTransport", package: "Server"),
                .product(name: "HTTPClientLive", package: "HTTPClient"),
                .product(name: "TestSupport", package: "TestSupport"),
            ],
            swiftSettings: swift6)
    ]
)
