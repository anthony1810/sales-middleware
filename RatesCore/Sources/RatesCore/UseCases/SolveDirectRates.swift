import Foundation

public struct SolveDirectRates: Sendable {
    private let target: Currency
    private let loadRates: @Sendable () async throws -> [Rate]

    public init(
        target: Currency,
        loadRates: @escaping @Sendable () async throws -> [Rate]
    ) {
        self.target = target
        self.loadRates = loadRates
    }

    public func execute() async throws -> [Currency: Decimal] {
        RateTable(try await loadRates())
            .addingDerivedInverses()
            .directRates(to: target)
    }
}
