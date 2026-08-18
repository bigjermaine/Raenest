import XCTest
@testable import Raenest

final class ValidateTransferUseCaseTests: XCTestCase {
    private let useCase = ValidateTransferUseCase()
    private let rules = TestFixtures.rules

    func testRejectsAmountBelowMinimum() {
        let result = useCase.execute(
            amount: 9.99,
            currency: "USD",
            beneficiary: TestFixtures.ada,
            rules: rules
        )

        XCTAssertEqual(result, .failure(.amountBelowMinimum(10)))
    }

    func testRejectsAmountAboveMaximum() {
        let result = useCase.execute(
            amount: 20_000.01,
            currency: "USD",
            beneficiary: TestFixtures.ada,
            rules: rules
        )

        XCTAssertEqual(result, .failure(.amountAboveMaximum(20_000)))
    }

    func testRejectsCurrencyNotInRules() {
        let result = useCase.execute(
            amount: 50,
            currency: "JPY",
            beneficiary: TestFixtures.ada,
            rules: rules
        )

        XCTAssertEqual(result, .failure(.currencyNotAllowed("JPY")))
    }

    func testRejectsBeneficiaryThatDoesNotReceiveSelectedCurrency() {
        let result = useCase.execute(
            amount: 50,
            currency: "USD",
            beneficiary: TestFixtures.ada,
            rules: rules
        )

        XCTAssertEqual(
            result,
            .failure(.beneficiaryCurrencyMismatch(expected: "USD", actual: "NGN"))
        )
    }

    func testAcceptsValidTransfer() {
        let result = useCase.execute(
            amount: 250,
            currency: "NGN",
            beneficiary: TestFixtures.ada,
            rules: rules
        )

        let expected = TransferDraft(amount: 250, currency: "NGN", beneficiary: TestFixtures.ada)
        XCTAssertEqual(result, .success(expected))
    }

    func testDecodesValidationRulesFromBundledJSONShape() throws {
        let json = """
        {
          "min_amount": 10,
          "max_amount": 20000,
          "allowed_currencies": ["USD", "NGN", "GBP", "EUR"]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(ValidationRules.self, from: json)

        XCTAssertEqual(decoded.minAmount, 10)
        XCTAssertEqual(decoded.maxAmount, 20_000)
        XCTAssertEqual(decoded.allowedCurrencies, ["USD", "NGN", "GBP", "EUR"])
    }
}
