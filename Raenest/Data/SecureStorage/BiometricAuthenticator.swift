import Foundation
import LocalAuthentication

protocol BiometricAuthenticating {
    func authenticate(reason: String) async throws -> LAContext
}

final class BiometricAuthenticator: BiometricAuthenticating {
    func authenticate(reason: String) async throws -> LAContext {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        context.localizedFallbackTitle = "Use Passcode"

        var evaluationError: NSError?
        let policy: LAPolicy

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &evaluationError) {
            policy = .deviceOwnerAuthenticationWithBiometrics
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &evaluationError) {
            policy = .deviceOwnerAuthentication
        } else {
            throw SendMoneyError.biometricsUnavailable
        }

        do {
            try await context.evaluatePolicy(policy, localizedReason: reason)
            return context
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .appCancel, .systemCancel:
                throw SendMoneyError.biometricCancelled
            default:
                throw SendMoneyError.biometricFailed
            }
        } catch {
            throw SendMoneyError.biometricFailed
        }
    }
}
