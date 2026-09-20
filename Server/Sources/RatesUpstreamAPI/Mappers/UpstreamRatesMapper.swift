import Foundation
import RatesCore

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum UpstreamRatesMapper {
    public enum Error: Swift.Error, Equatable {
        case invalidData
    }

    private static let okStatusCode = 200

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Rate] {
        guard response.statusCode == okStatusCode,
            let dtos = try? JSONDecoder().decode([UpstreamRateDTO].self, from: data)
        else {
            throw Error.invalidData
        }
        return try dtos.map(rate)
    }

    private static func rate(from dto: UpstreamRateDTO) throws -> Rate {
        guard let value = Decimal(string: "\(dto.rate)") else {
            throw Error.invalidData
        }
        return Rate(from: Currency(dto.from), to: Currency(dto.to), value: value)
    }

    private struct UpstreamRateDTO: Decodable {
        let from: String
        let to: String
        let rate: Double
    }
}
