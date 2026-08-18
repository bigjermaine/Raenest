import XCTest
@testable import Raenest

final class RemoteTransferRepositoryTests: XCTestCase {
    func testSendsAuthorizedPostToSendEndpoint() async throws {
        let client = APIClientStub()
        client.response = SendTransferResponse(
            transactionId: "txn-repo",
            status: "success",
            message: "Your money is on its way."
        )
        let repository = RemoteTransferRepository(client: client)
        let request = SendTransferRequest(amount: "150", currency: "NGN", beneficiaryId: "ben-001")

        let response = try await repository.send(request, token: "mock-token")

        XCTAssertEqual(response.transactionId, "txn-repo")
        XCTAssertEqual(client.lastRequest?.path, "/send")
        XCTAssertEqual(client.lastRequest?.method, .post)
        XCTAssertEqual(client.lastRequest?.headers["Authorization"], "Bearer mock-token")
    }

    func testWrapsUnknownClientErrors() async {
        let client = APIClientStub()
        client.error = APIClientError.invalidResponse
        let repository = RemoteTransferRepository(client: client)
        let request = SendTransferRequest(amount: "150", currency: "NGN", beneficiaryId: "ben-001")

        do {
            _ = try await repository.send(request, token: "mock-token")
            XCTFail("Expected the repository to wrap the client error")
        } catch {
            XCTAssertEqual(
                error as? SendMoneyError,
                .requestFailed("The transfer could not be completed. Please try again.")
            )
        }
    }
}

private final class APIClientStub: APIClient {
    var response: SendTransferResponse?
    var error: Error?
    private(set) var lastRequest: APIRequest?

    func send<Response: Decodable>(_ request: APIRequest) async throws -> Response {
        lastRequest = request
        if let error { throw error }
        guard let response, let typed = response as? Response else {
            throw APIClientError.decodingFailed
        }
        return typed
    }
}
