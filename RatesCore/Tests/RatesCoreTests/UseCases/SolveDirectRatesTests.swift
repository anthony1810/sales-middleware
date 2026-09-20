import Foundation
import Testing

@testable import RatesCore

struct SolveDirectRatesTests {

    @Test func execute_pairPointingAwayFromTheTarget_deliversTheDerivedRate() async throws {
        let sut = SolveDirectRates(target: "USD") {
            [Rate(from: "USD", to: "INR", value: dec("83.96"))]
        }

        let solved = try await sut.execute()

        #expect(solved == ["USD": 1, "INR": 1 / dec("83.96")])
    }

    @Test func execute_loaderFailure_rethrowsTheError() async {
        let sut = SolveDirectRates(target: "USD") {
            throw NSError(domain: "any", code: 0)
        }

        await #expect(throws: Error.self) {
            try await sut.execute()
        }
    }
}
