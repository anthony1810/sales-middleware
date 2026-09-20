import Foundation
import RatesCore

enum RatesResponseMapper {
    struct ResponseDTO: Codable, Equatable, Sendable {
        let rates: [String: String]
    }

    static func map(_ solved: [Currency: Decimal]) -> ResponseDTO {
        ResponseDTO(
            rates: Dictionary(
                uniqueKeysWithValues: solved.map { ($0.key.code, "\($0.value)") }
            )
        )
    }
}
