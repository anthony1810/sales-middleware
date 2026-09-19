import Foundation
import RatesCore
import Testing

struct RateTableTests {

    @Test func directRates_singleDirectEdge_deliversItsRateAndIdentity() {
        let table = RateTable([
            Rate(from: "EUR", to: "USD", value: dec("1.18"))
        ])

        #expect(table.directRates(to: "USD") == ["EUR": dec("1.18"), "USD": 1])
    }

    @Test func directRates_twoHopChain_deliversTheExactProduct() {
        let table = RateTable([
            Rate(from: "GBP", to: "EUR", value: dec("1.12")),
            Rate(from: "EUR", to: "USD", value: dec("1.18")),
        ])

        #expect(
            table.directRates(to: "USD") == ["GBP": dec("1.3216"), "EUR": dec("1.18"), "USD": 1]
        )
    }
}
