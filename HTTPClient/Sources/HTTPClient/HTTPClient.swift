import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol HTTPClient: Sendable {
    func get(from url: URL) async throws -> (Data, HTTPURLResponse)
}
