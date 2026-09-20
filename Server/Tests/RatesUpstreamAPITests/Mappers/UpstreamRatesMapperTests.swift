import Foundation
import RatesCore
import Testing

@testable import RatesUpstreamAPI

struct UpstreamRatesMapperTests {

    @Test func map_jsonNumberRate_deliversTheExactDecimal() throws {
        let json = Data(
            """
            [{ "from": "JPY", "to": "GBP", "rate": 0.007 }]
            """.utf8
        )

        let rates = try UpstreamRatesMapper.map(json)

        #expect(rates == [Rate(from: "JPY", to: "GBP", value: dec("0.007"))])
    }
}
