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

    @Test func directRates_cycleInTheGraph_solvesEachCurrencyOnce() {
        let table = RateTable([
            Rate(from: "EUR", to: "GBP", value: dec("0.89")),
            Rate(from: "GBP", to: "EUR", value: dec("1.12")),
            Rate(from: "GBP", to: "USD", value: dec("1.32")),
        ])

        #expect(
            table.directRates(to: "USD") == [
                "GBP": dec("1.32"),
                "EUR": dec("1.1748"),  // 0.89 × 1.32
                "USD": 1,
            ]
        )
    }

    @Test func directRates_currencyWithBothAShortAndALongPath_usesTheFewestSteps() {
        let table = RateTable([
            Rate(from: "AUD", to: "USD", value: dec("2")),
            Rate(from: "AUD", to: "EUR", value: dec("1")),
            Rate(from: "EUR", to: "USD", value: dec("1.9")),
        ])

        #expect(
            table.directRates(to: "USD") == [
                "AUD": dec("2"),  // the direct edge, not 1 × 1.9 through EUR
                "EUR": dec("1.9"),
                "USD": 1,
            ]
        )
    }

    @Test func addingDerivedInverses_missingReversePair_addsItAsOneOverRate() {
        let table = RateTable([
            Rate(from: "USD", to: "INR", value: dec("83.96"))
        ])

        let solved = table.addingDerivedInverses().directRates(to: "USD")

        #expect(solved == ["INR": 1 / dec("83.96"), "USD": 1])
    }

    @Test func addingDerivedInverses_pairProvidedBothWays_keepsTheProvidedRates() {
        let providedReverse = Rate(from: "USD", to: "EUR", value: dec("0.9"))
        let table = RateTable([
            Rate(from: "EUR", to: "USD", value: dec("1.18")),
            providedReverse,
        ])

        let solved = table.addingDerivedInverses().directRates(to: "EUR")

        #expect(solved == ["USD": providedReverse.value, "EUR": 1])
    }

    @Test func directRates_realUpstreamPairsWithDerivedInverses_solveEveryCurrency() {
        let upstreamPairs = RateTable([
            Rate(from: "EUR", to: "USD", value: dec("1.18")),
            Rate(from: "GBP", to: "EUR", value: dec("1.12")),
            Rate(from: "CAD", to: "JPY", value: dec("80")),
            Rate(from: "BRL", to: "CAD", value: dec("0.19")),
            Rate(from: "JPY", to: "GBP", value: dec("0.007")),
            Rate(from: "AUD", to: "ZAR", value: dec("10")),
            Rate(from: "ZAR", to: "INR", value: dec("5")),
            Rate(from: "USD", to: "INR", value: dec("83.96")),
        ])

        let solved = upstreamPairs.addingDerivedInverses().directRates(to: "USD")

        #expect(
            Set(solved.keys) == [
                "USD", "EUR", "GBP", "JPY", "CAD", "BRL", "INR", "ZAR", "AUD",
            ]
        )
        #expect(solved["INR"] == 1 / dec("83.96"))
        #expect(solved["AUD"] == dec("10") * (dec("5") * (1 / dec("83.96"))))
    }
}
