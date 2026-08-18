import XCTest
@testable import Raenest

final class FilterBeneficiariesUseCaseTests: XCTestCase {
    private let useCase = FilterBeneficiariesUseCase()
    private let beneficiaries = [TestFixtures.ada, TestFixtures.kwame]

    func testEmptyQueryReturnsOnlyBeneficiariesInSelectedCurrency() {
        XCTAssertEqual(
            useCase.execute(beneficiaries: beneficiaries, query: "  ", currency: "USD"),
            [TestFixtures.kwame]
        )
        XCTAssertEqual(
            useCase.execute(beneficiaries: beneficiaries, query: "", currency: "NGN"),
            [TestFixtures.ada]
        )
    }

    func testFiltersByNameBankOrAccountWithinCurrency() {
        XCTAssertEqual(
            useCase.execute(beneficiaries: beneficiaries, query: "adaeze", currency: "NGN"),
            [TestFixtures.ada]
        )
        XCTAssertEqual(
            useCase.execute(beneficiaries: beneficiaries, query: "adaeze", currency: "USD"),
            []
        )
        XCTAssertEqual(
            useCase.execute(beneficiaries: beneficiaries, query: "ecobank", currency: "USD"),
            [TestFixtures.kwame]
        )
    }
}
