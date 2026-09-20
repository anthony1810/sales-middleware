import Foundation
import RatesCore
import TestSupport
import Testing

@testable import RatesUpstreamAPI

struct UpstreamRatesMapperTests {

    @Test func map_jsonNumberRate_deliversTheExactDecimal() throws {
        let rates = try UpstreamRatesMapper.map(
            validRatesJSON(),
            from: okHTTPURLResponse(for: anyURL())
        )

        #expect(rates == [Rate(from: "JPY", to: "GBP", value: dec("0.007"))])
    }

    @Test(arguments: [199, 201, 300, 400, 500])
    func map_non200Response_throwsInvalidData(statusCode: Int) {
        #expect(throws: UpstreamRatesMapper.Error.invalidData) {
            try UpstreamRatesMapper.map(
                validRatesJSON(),
                from: anyHTTPURLResponse(statusCode: statusCode)
            )
        }
    }

    @Test func map_invalidJSONWithOKStatus_throwsInvalidData() {
        #expect(throws: UpstreamRatesMapper.Error.invalidData) {
            try UpstreamRatesMapper.map(invalidJSON(), from: okHTTPURLResponse(for: anyURL()))
        }
    }

    // MARK: - Helpers

    private func validRatesJSON() -> Data {
        Data(
            """
            [{ "from": "JPY", "to": "GBP", "rate": 0.007 }]
            """.utf8
        )
    }
}
