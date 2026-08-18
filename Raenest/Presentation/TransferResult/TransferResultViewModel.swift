import Foundation

struct TransferResultViewModel: Equatable {
    enum Kind: Equatable {
        case success(SendTransferResponse)
        case failure(String)
    }

    let kind: Kind
    let draft: TransferDraft

    var title: String {
        switch kind {
        case .success: return "Transfer sent"
        case .failure: return "Transfer failed"
        }
    }

    var message: String {
        switch kind {
        case .success(let response):
            return "\(response.message)\n\n\(MoneyFormatter.display(amount: draft.amount, currency: draft.currency)) to \(draft.beneficiary.name)."
        case .failure(let reason):
            return reason
        }
    }

    var symbolName: String {
        switch kind {
        case .success: return "checkmark.circle.fill"
        case .failure: return "xmark.circle.fill"
        }
    }

    var isSuccess: Bool {
        if case .success = kind { return true }
        return false
    }

    var primaryActionTitle: String {
        isSuccess ? "Done" : "Try again"
    }

    var referenceText: String? {
        if case .success(let response) = kind {
            return "Ref \(response.transactionId)"
        }
        return nil
    }
}
