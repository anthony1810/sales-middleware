import RatesCore

public actor StaleOnErrorRatesLoader {
    private let loader: @Sendable () async throws -> [Rate]
    private var lastGoodRates: [Rate]?

    public init(loader: @escaping @Sendable () async throws -> [Rate]) {
        self.loader = loader
    }

    public func load() async throws -> [Rate] {
        do {
            let fresh = try await loader()
            lastGoodRates = fresh
            return fresh
        } catch {
            guard let lastGoodRates else { throw error }
            return lastGoodRates
        }
    }
}
