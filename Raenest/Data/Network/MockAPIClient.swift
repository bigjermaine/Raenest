import Foundation

/// In-memory stand-in for a real HTTP client. Swap this for `URLSessionAPIClient`
/// in `AppDependencyContainer` when a backend is available.
final class MockAPIClient: APIClient {
    var simulatedDelayNanoseconds: UInt64 = 700_000_000

    func send<Response: Decodable>(_ request: APIRequest) async throws -> Response {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)

        guard request.path == "/send", request.method == .post else {
            throw APIClientError.invalidURL
        }

        if let body = request.body,
           let payload = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
           let amount = payload["amount"] as? String,
           amount == "404" {
            throw SendMoneyError.requestFailed("The transfer could not be completed. Please try again.")
        }

        let response = SendTransferResponse(
            transactionId: "txn-\(UUID().uuidString.prefix(8))",
            status: "success",
            message: "Your money is on its way."
        )

        let data = try JSONEncoder().encode(response)
        return try JSONDecoder().decode(Response.self, from: data)
    }
}
