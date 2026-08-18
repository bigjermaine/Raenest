import Foundation

struct ValidateTransferUseCase: Sendable {
    func execute(
        amount: Decimal?,
        currency: String?,
        beneficiary: Beneficiary?,
        rules: ValidationRules
    ) -> Result<TransferDraft, TransferValidationError> {
        guard let amount else {
            return .failure(.amountMissing)
        }

        if amount < rules.minAmount {
            return .failure(.amountBelowMinimum(rules.minAmount))
        }

        if amount > rules.maxAmount {
            return .failure(.amountAboveMaximum(rules.maxAmount))
        }

        guard let currency, !currency.isEmpty else {
            return .failure(.currencyNotAllowed(""))
        }

        guard rules.allowedCurrencies.contains(currency) else {
            return .failure(.currencyNotAllowed(currency))
        }

        guard let beneficiary else {
            return .failure(.beneficiaryMissing)
        }

        guard beneficiary.currency == currency else {
            return .failure(.beneficiaryCurrencyMismatch(expected: currency, actual: beneficiary.currency))
        }

        return .success(
            TransferDraft(amount: amount, currency: currency, beneficiary: beneficiary)
        )
    }
}
