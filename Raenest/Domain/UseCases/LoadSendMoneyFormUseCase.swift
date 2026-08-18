import Foundation

struct SendMoneyFormData: Equatable, Sendable {
    let beneficiaries: [Beneficiary]
    let rules: ValidationRules
}

struct LoadSendMoneyFormUseCase {
    private let beneficiaryRepository: BeneficiaryRepository
    private let validationRulesRepository: ValidationRulesRepository

    init(
        beneficiaryRepository: BeneficiaryRepository,
        validationRulesRepository: ValidationRulesRepository
    ) {
        self.beneficiaryRepository = beneficiaryRepository
        self.validationRulesRepository = validationRulesRepository
    }

    func execute() throws -> SendMoneyFormData {
        let beneficiaries = try beneficiaryRepository.fetchBeneficiaries()
        let rules = try validationRulesRepository.fetchRules()
        return SendMoneyFormData(beneficiaries: beneficiaries, rules: rules)
    }
}
