import Foundation
import HTTPClient
import TestSupport

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

actor HTTPClientSpy: HTTPClient {
    enum Message: Equatable {
        case get(URL)
    }

    private(set) var receivedMessages: [Message] = []
    private var stubbedData: Data?

    func stub(_ data: Data) {
        stubbedData = data
    }

    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        receivedMessages.append(.get(url))
        guard let data = stubbedData else { throw SpyError.resultNotSet }
        return (data, okHTTPURLResponse(for: url))
    }
}
