import Foundation
import HTTPClientLive
import RatesCore
import RatesTransport
import RatesUpstreamAPI
import TestSupport
import Testing

struct RatesAPIEndToEndTests {

    @Test func execute_realUpstream_solvesEveryKnownCurrencyToUSD() async throws {
        let realEnvironment: [String: String] = [:]
        let upstreamURL = ServerConfiguration(environment: realEnvironment).upstreamURL
        let loader = RemoteRatesLoader(
            url: upstreamURL,
            client: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        )
        let sut = SolveDirectRates(target: "USD", loadRates: loader.load)

        let solved = try await sut.execute()

        let knownCurrencies: Set<Currency> = [
            "USD", "EUR", "GBP", "JPY", "CAD", "BRL", "INR", "ZAR", "AUD",
        ]
        #expect(knownCurrencies.isSubset(of: Set(solved.keys)))
        #expect(solved["USD"] == 1)
    }
}
