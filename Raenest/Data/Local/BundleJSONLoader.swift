import Foundation

enum BundleJSONError: Equatable, Error {
    case fileNotFound(String)
}

enum BundleJSONLoader {
    static func data(named name: String, subdirectory: String? = "Resources", in bundle: Bundle) throws -> Data {
        if let url = bundle.url(forResource: name, withExtension: "json", subdirectory: subdirectory) {
            return try Data(contentsOf: url)
        }

        if let url = bundle.url(forResource: name, withExtension: "json") {
            return try Data(contentsOf: url)
        }

        throw BundleJSONError.fileNotFound(name)
    }
}
