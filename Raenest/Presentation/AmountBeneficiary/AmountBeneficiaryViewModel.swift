import Foundation

@MainActor
final class AmountBeneficiaryViewModel {
    struct State: Equatable {
        var amountText = ""
        var selectedCurrency = "USD"
        var searchQuery = ""
        var beneficiaries: [Beneficiary] = []
        var filteredBeneficiaries: [Beneficiary] = []
        var selectedBeneficiaryID: String?
        var allowedCurrencies: [String] = []
        var validationMessage: String?
        var isContinueEnabled = false
        var isLoading = true
        var loadError: String?
    }

    private(set) var state = State() {
        didSet { onStateChange?(state) }
    }

    var onStateChange: ((State) -> Void)?
    var onContinue: ((TransferDraft) -> Void)?

    private let loadForm: LoadSendMoneyFormUseCase
    private let validateTransfer: ValidateTransferUseCase
    private let filterBeneficiaries: FilterBeneficiariesUseCase
    private var rules: ValidationRules?

    init(
        loadForm: LoadSendMoneyFormUseCase,
        validateTransfer: ValidateTransferUseCase = ValidateTransferUseCase(),
        filterBeneficiaries: FilterBeneficiariesUseCase = FilterBeneficiariesUseCase()
    ) {
        self.loadForm = loadForm
        self.validateTransfer = validateTransfer
        self.filterBeneficiaries = filterBeneficiaries
    }

    func load() {
        state.isLoading = true
        state.loadError = nil

        do {
            let form = try loadForm.execute()
            rules = form.rules
            state.beneficiaries = form.beneficiaries
            state.allowedCurrencies = form.rules.allowedCurrencies
            if let first = form.rules.allowedCurrencies.first {
                state.selectedCurrency = first
            }
            applyFiltersAndValidation()
            state.isLoading = false
        } catch {
            state.isLoading = false
            state.loadError = "We could not load transfer details. Please restart the app."
        }
    }

    func updateAmount(_ text: String) {
        state.amountText = text
        applyFiltersAndValidation()
    }

    func selectCurrency(_ currency: String) {
        state.selectedCurrency = currency
        if let selected = state.beneficiaries.first(where: { $0.id == state.selectedBeneficiaryID }),
           selected.currency != currency {
            state.selectedBeneficiaryID = nil
        }
        applyFiltersAndValidation()
    }

    func updateSearch(_ query: String) {
        state.searchQuery = query
        applyFiltersAndValidation()
    }

    func selectBeneficiary(_ beneficiary: Beneficiary) {
        if state.selectedBeneficiaryID == beneficiary.id {
            state.selectedBeneficiaryID = nil
        } else {
            state.selectedBeneficiaryID = beneficiary.id
        }
        applyFiltersAndValidation()
    }

    func continueTapped() {
        guard case .success(let draft) = currentValidation() else { return }
        onContinue?(draft)
    }

    private func applyFiltersAndValidation() {
        state.filteredBeneficiaries = filterBeneficiaries.execute(
            beneficiaries: state.beneficiaries,
            query: state.searchQuery,
            currency: state.selectedCurrency
        )

        switch currentValidation() {
        case .success:
            state.validationMessage = nil
            state.isContinueEnabled = true
        case .failure(let error):
            state.isContinueEnabled = false
            if case .amountMissing = error {
                state.validationMessage = state.amountText.isEmpty ? nil : error.localizedDescription
            } else if case .beneficiaryMissing = error {
                state.validationMessage = parsedAmount() == nil && !state.amountText.isEmpty
                    ? TransferValidationError.amountMissing.localizedDescription
                    : nil
            } else {
                state.validationMessage = error.localizedDescription
            }
        }
    }

    private func currentValidation() -> Result<TransferDraft, TransferValidationError> {
        guard let rules else {
            return .failure(.amountMissing)
        }

        let selected = state.beneficiaries.first { $0.id == state.selectedBeneficiaryID }
        return validateTransfer.execute(
            amount: parsedAmount(),
            currency: state.selectedCurrency,
            beneficiary: selected,
            rules: rules
        )
    }

    private func parsedAmount() -> Decimal? {
        let trimmed = state.amountText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if let number = formatter.number(from: trimmed) {
            return number.decimalValue
        }
        return Decimal(string: trimmed)
    }
}
