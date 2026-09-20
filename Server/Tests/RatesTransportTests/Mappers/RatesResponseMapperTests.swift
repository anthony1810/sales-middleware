import Foundation
import RatesCore
import TestSupport
import Testing

@testable import RatesTransport

struct RatesResponseMapperTests {

    @Test func map_solvedTable_deliversDecimalStringsKeyedByCurrencyCode() {
        let solved: [Currency: Decimal] = [
            "USD": 1,
            "EUR": dec("1.18"),
            "JPY": dec("0.0092512"),
        ]

        let dto = RatesResponseMapper.map(solved)

        #expect(
            dto
                == RatesResponseMapper.ResponseDTO(rates: [
                    "USD": "1",
                    "EUR": "1.18",
                    "JPY": "0.0092512",
                ])
        )
    }
}
