import Foundation

struct ValidationRules: Equatable, Sendable {
    let minAmount: Decimal
    let maxAmount: Decimal
    let allowedCurrencies: [String]
}

extension ValidationRules: Decodable {
    enum CodingKeys: String, CodingKey {
        case minAmount = "min_amount"
        case maxAmount = "max_amount"
        case allowedCurrencies = "allowed_currencies"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        minAmount = Decimal(try container.decode(Double.self, forKey: .minAmount))
        maxAmount = Decimal(try container.decode(Double.self, forKey: .maxAmount))
        allowedCurrencies = try container.decode([String].self, forKey: .allowedCurrencies)
    }
}
