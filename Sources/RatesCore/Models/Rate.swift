import Foundation

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
