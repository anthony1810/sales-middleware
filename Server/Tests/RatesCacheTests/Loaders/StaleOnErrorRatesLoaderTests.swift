import RatesCore
import TestSupport
import Testing

@testable import RatesCache

struct StaleOnErrorRatesLoaderTests {

    @Test func load_upstreamFailureWithAPriorSuccess_deliversTheLastGoodRates() async throws {
        let (sut, upstream, lastGoodRates) = makeSUT()

        let first = try await sut.load()
        upstream.complete(with: .failure(anyNSError()))
        let second = try await sut.load()

        #expect(first == lastGoodRates)
        #expect(second == lastGoodRates)
    }

    @Test func load_upstreamFailureWithNoPriorSuccess_rethrowsTheError() async {
        let (sut, upstream, _) = makeSUT()
        upstream.complete(with: .failure(anyNSError()))

        await #expect(throws: Error.self) {
            try await sut.load()
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> (
        sut: StaleOnErrorRatesLoader,
        upstream: Stub<[Rate]>,
        lastGoodRates: [Rate]
    ) {
        let lastGoodRates = [Rate(from: "EUR", to: "USD", value: dec("1.18"))]
        let upstream = Stub<[Rate]>(.success(lastGoodRates))
        let sut = StaleOnErrorRatesLoader(loader: upstream.call)
        return (sut, upstream, lastGoodRates)
    }
}
