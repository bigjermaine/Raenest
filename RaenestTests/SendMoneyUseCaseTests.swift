import XCTest
@testable import Raenest

final class SendMoneyUseCaseTests: XCTestCase {
    func testSendsAfterRetrievingToken() async throws {
        let tokens = TokenRepositoryStub()
        let transfers = TransferRepositoryStub()
        let useCase = SendMoneyUseCase(tokenRepository: tokens, transferRepository: transfers)
        let draft = TransferDraft(amount: 150, currency: "USD", beneficiary: TestFixtures.ada)

        let response = try await useCase.execute(draft)

        XCTAssertEqual(response.transactionId, "txn-test")
        XCTAssertEqual(transfers.lastToken, "mock-token")
        XCTAssertEqual(transfers.lastRequest?.beneficiaryId, TestFixtures.ada.id)
        XCTAssertEqual(transfers.lastRequest?.amount, "150")
        XCTAssertEqual(transfers.lastRequest?.currency, "USD")
    }

    func testDoesNotCallAPIWhenBiometricsAreCancelled() async {
        let tokens = TokenRepositoryStub()
        tokens.error = SendMoneyError.biometricCancelled
        let transfers = TransferRepositoryStub()
        let useCase = SendMoneyUseCase(tokenRepository: tokens, transferRepository: transfers)
        let draft = TransferDraft(amount: 150, currency: "USD", beneficiary: TestFixtures.ada)

        do {
            _ = try await useCase.execute(draft)
            XCTFail("Expected biometric cancellation to throw")
        } catch {
            XCTAssertEqual(error as? SendMoneyError, .biometricCancelled)
            XCTAssertNil(transfers.lastRequest)
        }
    }
}
