import Foundation

final class LocalBeneficiaryRepository: BeneficiaryRepository {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func fetchBeneficiaries() throws -> [Beneficiary] {
        let data = try BundleJSONLoader.data(named: "beneficiaries", in: bundle)
        return try JSONDecoder().decode([Beneficiary].self, from: data)
    }
}
