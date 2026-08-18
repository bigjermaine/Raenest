import XCTest
@testable import Raenest

@MainActor
final class AmountBeneficiaryViewModelTests: XCTestCase {
    private func makeViewModel() -> AmountBeneficiaryViewModel {
        AmountBeneficiaryViewModel(
            loadForm: LoadSendMoneyFormUseCase(
                beneficiaryRepository: BeneficiaryRepositoryStub(),
                validationRulesRepository: ValidationRulesRepositoryStub()
            )
        )
    }

    func testContinueStaysDisabledUntilAmountCurrencyAndBeneficiaryAreValid() {
        let viewModel = makeViewModel()
        viewModel.load()

        XCTAssertFalse(viewModel.state.isContinueEnabled)

        viewModel.updateAmount("25")
        XCTAssertFalse(viewModel.state.isContinueEnabled)
        XCTAssertNil(viewModel.state.validationMessage)

        viewModel.selectCurrency("NGN")
        viewModel.selectBeneficiary(TestFixtures.ada)
        XCTAssertTrue(viewModel.state.isContinueEnabled)
    }

    func testContinueStaysDisabledWhenBeneficiaryCurrencyDoesNotMatch() {
        let viewModel = makeViewModel()
        viewModel.load()
        viewModel.updateAmount("25")
        viewModel.selectCurrency("USD")
        viewModel.selectBeneficiary(TestFixtures.ada)

        XCTAssertFalse(viewModel.state.isContinueEnabled)
        XCTAssertEqual(
            viewModel.state.validationMessage,
            TransferValidationError.beneficiaryCurrencyMismatch(expected: "USD", actual: "NGN").localizedDescription
        )
    }

    func testChangingCurrencyClearsIncompatibleBeneficiaryAndFiltersList() {
        let viewModel = makeViewModel()
        viewModel.load()
        viewModel.selectCurrency("NGN")
        viewModel.selectBeneficiary(TestFixtures.ada)
        viewModel.selectCurrency("USD")

        XCTAssertNil(viewModel.state.selectedBeneficiaryID)
        XCTAssertEqual(viewModel.state.filteredBeneficiaries, [TestFixtures.kwame])
    }

    func testSearchFiltersVisibleBeneficiaries() {
        let viewModel = makeViewModel()
        viewModel.load()
        viewModel.selectCurrency("USD")
        viewModel.updateSearch("ghana")

        XCTAssertEqual(viewModel.state.filteredBeneficiaries, [TestFixtures.kwame])
    }
}
