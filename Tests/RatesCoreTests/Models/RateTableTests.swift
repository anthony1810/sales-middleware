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
            table.directRates(to: "USD") == [
                "GBP": dec("1.3216"),  // 1.12 × 1.18
                "EUR": dec("1.18"),
                "USD": 1,
            ]
        )
    }

    @Test func directRates_fiveHopChain_deliversTheExactProduct() {
        let table = RateTable([
            Rate(from: "BRL", to: "CAD", value: dec("0.19")),
            Rate(from: "CAD", to: "JPY", value: dec("80")),
            Rate(from: "JPY", to: "GBP", value: dec("0.007")),
            Rate(from: "GBP", to: "EUR", value: dec("1.12")),
            Rate(from: "EUR", to: "USD", value: dec("1.18")),
        ])

        #expect(
            table.directRates(to: "USD") == [
                "BRL": dec("0.14061824"),  // 0.19 × 0.740096
                "CAD": dec("0.740096"),  // 80 × 0.0092512
                "JPY": dec("0.0092512"),  // 0.007 × 1.3216
                "GBP": dec("1.3216"),  // 1.12 × 1.18
                "EUR": dec("1.18"),
                "USD": 1,
            ]
        )
    }

    @Test func directRates_currenciesWithNoPathToTarget_leavesThemOut() {
        let table = RateTable([
            Rate(from: "EUR", to: "USD", value: dec("1.18")),
            Rate(from: "AUD", to: "ZAR", value: dec("10")),
            Rate(from: "ZAR", to: "INR", value: dec("5")),
        ])

        #expect(table.directRates(to: "USD") == ["EUR": dec("1.18"), "USD": 1])
    }
}
