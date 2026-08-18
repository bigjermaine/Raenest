import Foundation

final class KeychainTokenRepository: TokenRepository {
    static let tokenKey = "mock.auth.token.v2"

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
        guard !store.itemExists(Self.tokenKey) else { return }
        try store.setProtected("mock-token-\(UUID().uuidString)", for: Self.tokenKey)
    }

    func tokenRequiringBiometrics() async throws -> String {
        let context = try await authenticator.authenticate(
            reason: "Confirm this transfer with Face ID or Touch ID."
        )
        do {
            return try store.getProtected(Self.tokenKey, context: context)
        } catch {
            throw KeychainAuthMapper.sendMoneyError(from: error)
        }
    }
}
