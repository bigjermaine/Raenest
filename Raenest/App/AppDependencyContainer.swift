import UIKit

@MainActor
final class AppDependencyContainer {
    private let beneficiaryRepository: BeneficiaryRepository
    private let validationRulesRepository: ValidationRulesRepository
    private let tokenRepository: TokenRepository
    private let transferRepository: TransferRepository

    init(
        beneficiaryRepository: BeneficiaryRepository = LocalBeneficiaryRepository(),
        validationRulesRepository: ValidationRulesRepository = LocalValidationRulesRepository(),
        tokenRepository: TokenRepository = KeychainTokenRepository(),
        apiClient: APIClient = MockAPIClient()
    ) {
        self.beneficiaryRepository = beneficiaryRepository
        self.validationRulesRepository = validationRulesRepository
        self.tokenRepository = tokenRepository
        self.transferRepository = RemoteTransferRepository(client: apiClient)
    }

    func prepareSecureStorage() {
        try? tokenRepository.storeMockTokenIfNeeded()
    }

    func makeAmountBeneficiaryViewController(
        onContinue: @escaping (TransferDraft) -> Void
    ) -> AmountBeneficiaryViewController {
        let viewModel = AmountBeneficiaryViewModel(
            loadForm: LoadSendMoneyFormUseCase(
                beneficiaryRepository: beneficiaryRepository,
                validationRulesRepository: validationRulesRepository
            )
        )
        viewModel.onContinue = onContinue
        return AmountBeneficiaryViewController(viewModel: viewModel)
    }

    func makeConfirmSendViewController(
        draft: TransferDraft,
        onSuccess: @escaping (SendTransferResponse) -> Void,
        onFailure: @escaping (String) -> Void
    ) -> ConfirmSendViewController {
        let viewModel = ConfirmSendViewModel(
            draft: draft,
            sendMoney: SendMoneyUseCase(
                tokenRepository: tokenRepository,
                transferRepository: transferRepository
            )
        )
        viewModel.onSuccess = onSuccess
        viewModel.onFailure = onFailure
        return ConfirmSendViewController(viewModel: viewModel)
    }

    func makeResultViewController(
        viewModel: TransferResultViewModel,
        onPrimaryAction: @escaping () -> Void
    ) -> TransferResultViewController {
        let viewController = TransferResultViewController(viewModel: viewModel)
        viewController.onPrimaryAction = onPrimaryAction
        return viewController
    }
}
