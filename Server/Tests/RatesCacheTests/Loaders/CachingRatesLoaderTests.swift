import RatesCore
import TestSupport
import Testing

@testable import RatesCache

struct CachingRatesLoaderTests {

    @Test func load_secondLoadWithinTheTTL_hitsTheUpstreamOnce() async throws {
        let (sut, upstreamCalls, freshRates) = makeSUT()

        let first = try await sut.load()
        let second = try await sut.load()

        #expect(upstreamCalls.value == 1)
        #expect(first == freshRates)
        #expect(second == freshRates)
    }

    @Test func load_secondLoadNearTheTTLDeadline_hitsTheUpstreamOnce() async throws {
        let clock = TestClock()
        let (sut, upstreamCalls, _) = makeSUT(clock: clock)

        _ = try await sut.load()
        await clock.advance(by: .seconds(59))
        _ = try await sut.load()

        #expect(upstreamCalls.value == 1)
    }

    @Test func load_secondLoadAtTheTTLDeadline_hitsTheUpstreamAgain() async throws {
        let clock = TestClock()
        let (sut, upstreamCalls, _) = makeSUT(clock: clock)

        _ = try await sut.load()
        await clock.advance(by: .seconds(60))
        _ = try await sut.load()

        #expect(upstreamCalls.value == 2)
    }

    // MARK: - Helpers

    private func makeSUT(
        clock: TestClock<Duration> = TestClock()
    ) -> (
        sut: CachingRatesLoader<TestClock<Duration>>,
        upstreamCalls: LockIsolated<Int>,
        freshRates: [Rate]
    ) {
        let upstreamCalls = LockIsolated(0)
        let freshRates = [Rate(from: "EUR", to: "USD", value: dec("1.18"))]
        let sut = CachingRatesLoader(ttl: .seconds(60), clock: clock) {
            upstreamCalls.withValue { $0 += 1 }
            return freshRates
        }
        return (sut, upstreamCalls, freshRates)
    }
}
