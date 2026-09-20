public struct Currency: Hashable, Sendable, ExpressibleByStringLiteral {
    public let code: String

    public init(_ code: String) {
        self.code = code
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }
}
