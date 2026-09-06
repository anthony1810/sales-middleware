import Foundation

public struct Currency: Hashable, Sendable, ExpressibleByStringLiteral {
    public let code: String

    public init(_ code: String) {
        self.code = code
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

public struct Rate: Equatable, Sendable {
    public let from: Currency
    public let to: Currency
    public let value: Decimal

    public init(from: Currency, to: Currency, value: Decimal) {
        self.from = from
        self.to = to
        self.value = value
    }
}

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
