import Foundation

public struct ServerConfiguration: Equatable, Sendable {
    public let port: Int
    public let upstreamURL: URL

    private static let defaultPort = 8080
    private static let defaultUpstreamURL = URL(
        string: "https://ile-b2p4.essentialdeveloper.com/rates"
    )!
    private static let validPorts = 1...65535
    private static let validSchemes = ["http", "https"]

    public init(environment: [String: String]) {
        self.port = Self.validPort(environment["PORT"]) ?? Self.defaultPort
        self.upstreamURL = Self.validURL(environment["UPSTREAM_URL"]) ?? Self.defaultUpstreamURL
    }

    private static func validPort(_ override: String?) -> Int? {
        guard let port = override.flatMap(Int.init), validPorts.contains(port) else { return nil }
        return port
    }

    private static func validURL(_ override: String?) -> URL? {
        guard let url = override.flatMap(URL.init(string:)),
            let scheme = url.scheme, validSchemes.contains(scheme),
            url.host != nil
        else { return nil }
        return url
    }
}
