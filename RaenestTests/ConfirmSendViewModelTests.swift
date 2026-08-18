import XCTest
@testable import Raenest

@MainActor
final class ConfirmSendViewModelTests: XCTestCase {
    func testBiometricCancelStaysOnConfirmAndDoesNotFailTheTransfer() async {
        let tokens = TokenRepositoryStub()
        tokens.error = SendMoneyError.biometricCancelled
        let transfers = TransferRepositoryStub()
        let viewModel = ConfirmSendViewModel(
            draft: TransferDraft(amount: 150, currency: "NGN", beneficiary: TestFixtures.ada),
            sendMoney: SendMoneyUseCase(tokenRepository: tokens, transferRepository: transfers)
        )

        var didSucceed = false
        var didFail = false
        viewModel.onSuccess = { _ in didSucceed = true }
        viewModel.onFailure = { _ in didFail = true }

        await viewModel.confirm()

        XCTAssertFalse(didSucceed)
        XCTAssertFalse(didFail)
        XCTAssertEqual(viewModel.state.bannerMessage, SendMoneyError.biometricCancelled.localizedDescription)
        XCTAssertFalse(viewModel.state.isSending)
        XCTAssertNil(transfers.lastRequest)
    }

    func testRequestFailureNavigatesToErrorResult() async {
        let transfers = TransferRepositoryStub()
        transfers.error = SendMoneyError.requestFailed("The transfer could not be completed. Please try again.")
        let viewModel = ConfirmSendViewModel(
            draft: TransferDraft(amount: 150, currency: "NGN", beneficiary: TestFixtures.ada),
            sendMoney: SendMoneyUseCase(
                tokenRepository: TokenRepositoryStub(),
                transferRepository: transfers
            )
        )

        var failureMessage: String?
        viewModel.onFailure = { failureMessage = $0 }

        await viewModel.confirm()

        XCTAssertEqual(failureMessage, "The transfer could not be completed. Please try again.")
        XCTAssertNil(viewModel.state.bannerMessage)
    }
}
