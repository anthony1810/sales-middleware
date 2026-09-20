import RatesCore

public actor CachingRatesLoader<ClockType: Clock> where ClockType.Duration == Duration {
    private let ttl: Duration
    private let clock: ClockType
    private let loader: @Sendable () async throws -> [Rate]
    private var cached: (rates: [Rate], expiresAt: ClockType.Instant)?

    public init(
        ttl: Duration,
        clock: ClockType,
        loader: @escaping @Sendable () async throws -> [Rate]
    ) {
        self.ttl = ttl
        self.clock = clock
        self.loader = loader
    }

    public func load() async throws -> [Rate] {
        if let cached, clock.now < cached.expiresAt {
            return cached.rates
        }
        let fresh = try await loader()
        cached = (fresh, clock.now.advanced(by: ttl))
        return fresh
    }
}
