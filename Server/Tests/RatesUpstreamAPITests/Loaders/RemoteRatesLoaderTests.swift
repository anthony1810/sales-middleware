import Foundation
import RatesCore
import Testing

@testable import RatesUpstreamAPI

struct RemoteRatesLoaderTests {

    @Test func load_validUpstreamJSON_requestsTheURLOnceAndDeliversRates() async throws {
        let upstreamURL = URL(string: "https://upstream.example.com/rates")!
        let client = HTTPClientSpy()
        let sut = RemoteRatesLoader(url: upstreamURL, client: client)
        await client.stub(
            Data(
                """
                [{ "from": "EUR", "to": "USD", "rate": 1.18 }]
                """.utf8
            )
        )

        let rates = try await sut.load()

        #expect(await client.receivedMessages == [.get(upstreamURL)])
        #expect(rates == [Rate(from: "EUR", to: "USD", value: dec("1.18"))])
    }
}
