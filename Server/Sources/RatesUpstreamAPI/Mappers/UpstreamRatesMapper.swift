import Foundation
import RatesCore

public enum UpstreamRatesMapper {
    public static func map(_ data: Data) throws -> [Rate] {
        try JSONDecoder().decode([UpstreamRateDTO].self, from: data).map(rate)
    }

    private static func rate(from dto: UpstreamRateDTO) throws -> Rate {
        guard let value = Decimal(string: "\(dto.rate)") else {
            throw UpstreamRatesMapperError.unrepresentableRate
        }
        return Rate(from: Currency(dto.from), to: Currency(dto.to), value: value)
    }

    private struct UpstreamRateDTO: Decodable {
        let from: String
        let to: String
        let rate: Double
    }
}

public enum UpstreamRatesMapperError: Error {
    case unrepresentableRate
}
