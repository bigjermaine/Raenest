import Foundation

@MainActor
final class ConfirmSendViewModel {
    struct State: Equatable {
        var isSending = false
        var bannerMessage: String?
    }

    let draft: TransferDraft
    private(set) var state = State() {
        didSet { onStateChange?(state) }
    }

    var onStateChange: ((State) -> Void)?
    var onSuccess: ((SendTransferResponse) -> Void)?
    var onFailure: ((String) -> Void)?

    private let sendMoney: SendMoneyUseCase

    var amountText: String {
        MoneyFormatter.display(amount: draft.amount, currency: draft.currency)
    }

    var beneficiaryName: String { draft.beneficiary.name }
    var beneficiaryDetails: String {
        "\(draft.beneficiary.bankName)  ·  \(draft.beneficiary.maskedAccountNumber)"
    }
    var countryText: String { draft.beneficiary.country }

    init(draft: TransferDraft, sendMoney: SendMoneyUseCase) {
        self.draft = draft
        self.sendMoney = sendMoney
    }

    func confirm() async {
        guard !state.isSending else { return }
        state.isSending = true
        state.bannerMessage = nil

        do {
            let response = try await sendMoney.execute(draft)
            state.isSending = false
            onSuccess?(response)
        } catch let error as SendMoneyError {
            state.isSending = false
            switch error {
            case .biometricCancelled:
                state.bannerMessage = error.localizedDescription
            case .biometricFailed, .biometricsUnavailable, .tokenUnavailable:
                state.bannerMessage = error.localizedDescription
            case .requestFailed(let message):
                onFailure?(message)
            }
        } catch {
            state.isSending = false
            onFailure?(error.localizedDescription)
        }
    }
}
