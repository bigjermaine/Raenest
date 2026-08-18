import Foundation

struct FilterBeneficiariesUseCase: Sendable {
    func execute(beneficiaries: [Beneficiary], query: String, currency: String) -> [Beneficiary] {
        let matchingCurrency = beneficiaries.filter { $0.currency == currency }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return matchingCurrency }

        return matchingCurrency.filter { beneficiary in
            beneficiary.name.localizedCaseInsensitiveContains(trimmed)
                || beneficiary.bankName.localizedCaseInsensitiveContains(trimmed)
                || beneficiary.country.localizedCaseInsensitiveContains(trimmed)
                || beneficiary.accountNumber.contains(trimmed)
                || beneficiary.currency.localizedCaseInsensitiveContains(trimmed)
        }
    }
}
