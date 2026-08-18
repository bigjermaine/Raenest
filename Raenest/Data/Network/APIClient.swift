import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct APIRequest: Equatable {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let body: Data?

    init(
        path: String,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
    }
}

protocol APIClient {
    func send<Response: Decodable>(_ request: APIRequest) async throws -> Response
}

enum APIClientError: Equatable, Error {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed
}
