import Foundation
import Testing
import RatesCore

struct RatesCoreTests {

    @Test func directRates_singleDirectEdge_deliversItsRateAndIdentity() {
        let table = RateTable([Rate(from: "EUR", to: "USD", value: dec("1.18"))])

        #expect(table.directRates(to: "USD") == ["EUR": dec("1.18"), "USD": 1])
    }

    // MARK: - Helpers

    private func dec(_ value: String) -> Decimal {
        Decimal(string: value)!
    }
}
