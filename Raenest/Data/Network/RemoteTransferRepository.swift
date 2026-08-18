import Foundation

final class RemoteTransferRepository: TransferRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func send(_ request: SendTransferRequest, token: String) async throws -> SendTransferResponse {
        let body = try JSONEncoder().encode(request)
        let apiRequest = APIRequest(
            path: "/send",
            method: .post,
            headers: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ],
            body: body
        )

        do {
            return try await client.send(apiRequest)
        } catch let error as SendMoneyError {
            throw error
        } catch {
            throw SendMoneyError.requestFailed("The transfer could not be completed. Please try again.")
        }
    }
}
