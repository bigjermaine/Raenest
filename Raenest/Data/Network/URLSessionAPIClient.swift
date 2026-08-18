import Foundation

final class URLSessionAPIClient: APIClient {
    private let session: URLSession
    private let baseURL: URL

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func send<Response: Decodable>(_ request: APIRequest) async throws -> Response {
        guard let url = URL(string: request.path, relativeTo: baseURL) else {
            throw APIClientError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        request.headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await session.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIClientError.httpStatus(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw APIClientError.decodingFailed
        }
    }
}
