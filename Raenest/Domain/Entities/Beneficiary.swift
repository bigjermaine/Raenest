import Foundation

struct Beneficiary: Equatable, Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let accountNumber: String
    let bankName: String
    let country: String
    let currency: String

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return letters.map(String.init).joined().uppercased()
    }

    var maskedAccountNumber: String {
        let suffix = accountNumber.suffix(4)
        return "•••• \(suffix)"
    }
}
