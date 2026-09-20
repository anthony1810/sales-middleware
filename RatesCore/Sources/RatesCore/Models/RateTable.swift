import Foundation

public struct RateTable: Sendable {
    private let rates: [Rate]

    public init(_ rates: [Rate]) {
        self.rates = rates.filter { $0.value > 0 }
    }

    public func addingDerivedInverses() -> RateTable {
        let provided = Set(rates.map(DirectedPair.init))
        let derived =
            rates
            .filter { !provided.contains(DirectedPair(from: $0.to, to: $0.from)) }
            .map { Rate(from: $0.to, to: $0.from, value: 1 / $0.value) }

        return RateTable(rates + derived)
    }

    public func directRates(to target: Currency) -> [Currency: Decimal] {
        var incoming: [Currency: [Rate]] = [:]
        for rate in rates {
            incoming[rate.to, default: []].append(rate)
        }

        var solved: [Currency: Decimal] = [target: 1]
        var frontier: [Currency] = [target]

        while !frontier.isEmpty {
            var next: [Currency] = []
            for node in frontier {
                for edge in incoming[node] ?? [] where solved[edge.from] == nil {
                    solved[edge.from] = edge.value * solved[node]!
                    next.append(edge.from)
                }
            }
            frontier = next
        }

        return solved
    }

    private struct DirectedPair: Hashable {
        let from: Currency
        let to: Currency

        init(from: Currency, to: Currency) {
            self.from = from
            self.to = to
        }

        init(_ rate: Rate) {
            self.init(from: rate.from, to: rate.to)
        }
    }
}
