import Foundation
import Hummingbird
import HummingbirdTesting
import RatesCore
import TestSupport
import Testing

@testable import RatesTransport

struct RatesRoutesTests {

    @Test func getRates_solvedRates_respondsOKWithDecimalStrings() async throws {
        let solved: [Currency: Decimal] = ["USD": 1, "EUR": dec("1.18")]
        let app = Application(router: RatesRoutes.router { solved })

        try await app.test(.router) { client in
            try await client.execute(uri: "/rates", method: .get) { response in
                #expect(response.status == .ok)
                let dto = try JSONDecoder().decode(
                    RatesResponseMapper.ResponseDTO.self,
                    from: Data(buffer: response.body)
                )
                #expect(dto == RatesResponseMapper.ResponseDTO(rates: ["USD": "1", "EUR": "1.18"]))
            }
        }
    }

    @Test func getRates_solveFailure_respondsInternalServerError() async throws {
        let app = Application(
            router: RatesRoutes.router { throw anyNSError() }
        )

        try await app.test(.router) { client in
            try await client.execute(uri: "/rates", method: .get) { response in
                #expect(response.status == .internalServerError)
            }
        }
    }
}
