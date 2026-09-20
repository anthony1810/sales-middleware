import Foundation
import Hummingbird
import RatesCore

public enum RatesRoutes {
    public static func router(
        solve: @escaping @Sendable () async throws -> [Currency: Decimal]
    ) -> Router<BasicRequestContext> {
        let router = Router()
        router.get("rates") { _, _ in
            RatesResponseMapper.map(try await solve())
        }
        return router
    }
}

extension RatesResponseMapper.ResponseDTO: ResponseEncodable {}
