import Foundation

struct TransferDraft: Equatable, Sendable {
    let amount: Decimal
    let currency: String
    let beneficiary: Beneficiary
}

struct SendTransferRequest: Equatable, Encodable, Sendable {
    let amount: String
    let currency: String
    let beneficiaryId: String
}

struct SendTransferResponse: Equatable, Codable, Sendable {
    let transactionId: String
    let status: String
    let message: String
}

enum TransferValidationError: Equatable, Error {
    case amountMissing
    case amountBelowMinimum(Decimal)
    case amountAboveMaximum(Decimal)
    case currencyNotAllowed(String)
    case beneficiaryMissing
    case beneficiaryCurrencyMismatch(expected: String, actual: String)
}

enum SendMoneyError: Equatable, Error {
    case biometricsUnavailable
    case biometricCancelled
    case biometricFailed
    case tokenUnavailable
    case requestFailed(String)
}

extension TransferValidationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .amountMissing:
            return "Enter an amount to continue."
        case .amountBelowMinimum(let minimum):
            return "Minimum amount is \(minimum.formattedPlain)."
        case .amountAboveMaximum(let maximum):
            return "Maximum amount is \(maximum.formattedPlain)."
        case .currencyNotAllowed(let currency):
            return "\(currency) is not supported."
        case .beneficiaryMissing:
            return "Select a beneficiary to continue."
        case .beneficiaryCurrencyMismatch(let expected, let actual):
            return "This beneficiary receives \(actual), not \(expected). Choose a matching recipient or currency."
        }
    }
}

extension SendMoneyError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .biometricsUnavailable:
            return "Biometric authentication is not available on this device."
        case .biometricCancelled:
            return "Authentication was cancelled."
        case .biometricFailed:
            return "We could not verify your identity. Please try again."
        case .tokenUnavailable:
            return "Your session token could not be retrieved."
        case .requestFailed(let message):
            return message
        }
    }
}

extension Decimal {
    var formattedPlain: String {
        NSDecimalNumber(decimal: self).stringValue
    }
}
