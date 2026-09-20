import Foundation

public struct ServerConfiguration: Equatable, Sendable {
    public let port: Int
    public let upstreamURL: URL

    private static let defaultPort = 8080
    private static let defaultUpstreamURL = URL(
        string: "https://ile-b2p4.essentialdeveloper.com/rates"
    )!

    public init(environment: [String: String]) {
        self.port = environment["PORT"].flatMap(Int.init) ?? Self.defaultPort
        self.upstreamURL =
            environment["UPSTREAM_URL"].flatMap(URL.init(string:)) ?? Self.defaultUpstreamURL
    }
}
