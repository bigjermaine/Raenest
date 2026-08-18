import Foundation

final class LocalValidationRulesRepository: ValidationRulesRepository {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func fetchRules() throws -> ValidationRules {
        let data = try BundleJSONLoader.data(named: "validation_rules", in: bundle)
        return try JSONDecoder().decode(ValidationRules.self, from: data)
    }
}
