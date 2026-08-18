import Foundation

final class KeychainTokenRepository: TokenRepository {
    static let tokenKey = "mock.auth.token"

    private let store: KeychainStoring
    private let authenticator: BiometricAuthenticating

    init(
        store: KeychainStoring = KeychainStore(),
        authenticator: BiometricAuthenticating = BiometricAuthenticator()
    ) {
        self.store = store
        self.authenticator = authenticator
    }

    func storeMockTokenIfNeeded() throws {
        do {
            _ = try store.get(Self.tokenKey)
        } catch KeychainStoreError.itemNotFound {
            try store.set("mock-token-\(UUID().uuidString)", for: Self.tokenKey)
        }
    }

    func tokenRequiringBiometrics() async throws -> String {
        try await authenticator.authenticate(reason: "Confirm this transfer with Face ID or Touch ID.")
        do {
            return try store.get(Self.tokenKey)
        } catch {
            throw SendMoneyError.tokenUnavailable
        }
    }
}
