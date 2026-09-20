import RatesCore
import Testing

struct RatesUpstreamAPITests {

    @Test func directRates_calledFromTheServerPackage_deliversRates() {
        let table = RateTable([Rate(from: "EUR", to: "USD", value: 1)])

        #expect(table.directRates(to: "USD") == ["EUR": 1, "USD": 1])
    }
}
