import XCTest
@testable import Raenest

final class LoadSendMoneyFormUseCaseTests: XCTestCase {
    func testLoadsBeneficiariesAndRulesTogether() throws {
        let useCase = LoadSendMoneyFormUseCase(
            beneficiaryRepository: BeneficiaryRepositoryStub(),
            validationRulesRepository: ValidationRulesRepositoryStub()
        )

        let form = try useCase.execute()

        XCTAssertEqual(form.beneficiaries, [TestFixtures.ada, TestFixtures.kwame])
        XCTAssertEqual(form.rules, TestFixtures.rules)
    }

    func testSurfacesRepositoryFailures() {
        let beneficiaries = BeneficiaryRepositoryStub()
        beneficiaries.error = BundleJSONError.fileNotFound("beneficiaries")
        let useCase = LoadSendMoneyFormUseCase(
            beneficiaryRepository: beneficiaries,
            validationRulesRepository: ValidationRulesRepositoryStub()
        )

        XCTAssertThrowsError(try useCase.execute())
    }
}
