import Foundation
import Testing

@testable import RatesTransport

struct ServerConfigurationTests {

    @Test func init_noOverrides_deliversThePortAndTheRealUpstream() {
        let noOverrides: [String: String] = [:]

        let configuration = ServerConfiguration(environment: noOverrides)

        #expect(configuration.port == 8080)
        #expect(
            configuration.upstreamURL == URL(
                string: "https://ile-b2p4.essentialdeveloper.com/rates"
            )!
        )
    }

    @Test func init_portAndUpstreamOverrides_deliversTheOverriddenValues() {
        let overrides = [
            "PORT": "9090",
            "UPSTREAM_URL": "https://upstream.example.com/rates",
        ]

        let configuration = ServerConfiguration(environment: overrides)

        #expect(configuration.port == 9090)
        #expect(configuration.upstreamURL == URL(string: "https://upstream.example.com/rates")!)
    }

    @Test func init_unparsableOverrides_fallsBackToTheDefaults() {
        let unparsable = [
            "PORT": "not-a-number",
            "UPSTREAM_URL": "",
        ]

        let configuration = ServerConfiguration(environment: unparsable)

        #expect(configuration.port == 8080)
        #expect(
            configuration.upstreamURL == URL(
                string: "https://ile-b2p4.essentialdeveloper.com/rates"
            )!
        )
    }
}
