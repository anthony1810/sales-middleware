// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HTTPClient",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "HTTPClient", targets: ["HTTPClient"]),
        .library(name: "HTTPClientLive", targets: ["HTTPClientLive"]),
    ],
    dependencies: [
        .package(path: "../TestSupport")
    ],
    targets: [
        .target(name: "HTTPClient"),
        .target(name: "HTTPClientLive", dependencies: ["HTTPClient"]),
        .testTarget(name: "HTTPClientLiveTests", dependencies: ["HTTPClientLive", "TestSupport"]),
    ],
    swiftLanguageModes: [.v6]
)
