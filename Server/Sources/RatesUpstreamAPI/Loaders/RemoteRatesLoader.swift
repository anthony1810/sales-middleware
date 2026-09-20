import Foundation
import HTTPClient
import RatesCore

public struct RemoteRatesLoader: Sendable {
    private let url: URL
    private let client: any HTTPClient

    public init(url: URL, client: any HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load() async throws -> [Rate] {
        let (data, _) = try await client.get(from: url)
        return try UpstreamRatesMapper.map(data)
    }
}
