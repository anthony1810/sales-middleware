import Foundation

public struct RateTable: Sendable {
    private let rates: [Rate]

    public init(_ rates: [Rate]) {
        self.rates = rates
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
}
