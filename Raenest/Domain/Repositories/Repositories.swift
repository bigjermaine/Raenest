import Foundation

protocol BeneficiaryRepository {
    func fetchBeneficiaries() throws -> [Beneficiary]
}

protocol ValidationRulesRepository {
    func fetchRules() throws -> ValidationRules
}

protocol TokenRepository {
    func storeMockTokenIfNeeded() throws
    func tokenRequiringBiometrics() async throws -> String
}

protocol TransferRepository {
    func send(_ request: SendTransferRequest, token: String) async throws -> SendTransferResponse
}
