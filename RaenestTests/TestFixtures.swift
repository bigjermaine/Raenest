import Foundation
@testable import Raenest

enum TestFixtures {
    static let ada = Beneficiary(
        id: "ben-001",
        name: "Adaeze Okonkwo",
        accountNumber: "0123456789",
        bankName: "GTBank",
        country: "Nigeria",
        currency: "NGN"
    )

    static let kwame = Beneficiary(
        id: "ben-002",
        name: "Kwame Mensah",
        accountNumber: "2048193301",
        bankName: "Ecobank",
        country: "Ghana",
        currency: "USD"
    )

    static let rules = ValidationRules(
        minAmount: 10,
        maxAmount: 20_000,
        allowedCurrencies: ["USD", "NGN", "GBP", "EUR"]
    )
}

final class BeneficiaryRepositoryStub: BeneficiaryRepository {
    var beneficiaries: [Beneficiary] = [TestFixtures.ada, TestFixtures.kwame]
    var error: Error?

    func fetchBeneficiaries() throws -> [Beneficiary] {
        if let error { throw error }
        return beneficiaries
    }
}

final class ValidationRulesRepositoryStub: ValidationRulesRepository {
    var rules: ValidationRules = TestFixtures.rules
    var error: Error?

    func fetchRules() throws -> ValidationRules {
        if let error { throw error }
        return rules
    }
}

final class TokenRepositoryStub: TokenRepository {
    var token = "mock-token"
    var error: Error?

    func storeMockTokenIfNeeded() throws {}

    func tokenRequiringBiometrics() async throws -> String {
        if let error { throw error }
        return token
    }
}

final class TransferRepositoryStub: TransferRepository {
    var response = SendTransferResponse(
        transactionId: "txn-test",
        status: "success",
        message: "Your money is on its way."
    )
    var error: Error?
    private(set) var lastToken: String?
    private(set) var lastRequest: SendTransferRequest?

    func send(_ request: SendTransferRequest, token: String) async throws -> SendTransferResponse {
        lastRequest = request
        lastToken = token
        if let error { throw error }
        return response
    }
}
