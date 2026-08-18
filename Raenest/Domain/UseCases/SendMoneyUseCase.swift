import Foundation

struct SendMoneyUseCase {
    private let tokenRepository: TokenRepository
    private let transferRepository: TransferRepository

    init(tokenRepository: TokenRepository, transferRepository: TransferRepository) {
        self.tokenRepository = tokenRepository
        self.transferRepository = transferRepository
    }

    func execute(_ draft: TransferDraft) async throws -> SendTransferResponse {
        let token = try await tokenRepository.tokenRequiringBiometrics()
        let request = SendTransferRequest(
            amount: draft.amount.formattedPlain,
            currency: draft.currency,
            beneficiaryId: draft.beneficiary.id
        )
        return try await transferRepository.send(request, token: token)
    }
}
