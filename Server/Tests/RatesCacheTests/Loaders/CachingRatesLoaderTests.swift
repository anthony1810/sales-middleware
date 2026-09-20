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

    @Test func load_concurrentMissesOnTheSameCache_hitTheUpstreamOnce() async throws {
        let gate = Gate()
        let upstreamCalls = LockIsolated(0)
        let freshRates = [Rate(from: "EUR", to: "USD", value: dec("1.18"))]
        let sut = CachingRatesLoader(ttl: .seconds(60), clock: TestClock()) {
            upstreamCalls.withValue { $0 += 1 }
            await gate.wait()
            return freshRates
        }

        async let first = sut.load()
        while upstreamCalls.value == 0 { await Task.yield() }
        async let second = sut.load()
        await Task.megaYield()
        gate.open()
        let firstRates = try await first
        let secondRates = try await second

        #expect(upstreamCalls.value == 1)
        #expect(firstRates == freshRates)
        #expect(secondRates == freshRates)
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
