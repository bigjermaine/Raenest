import Foundation
import LocalAuthentication

protocol BiometricAuthenticating {
    func authenticate(reason: String) async throws
}

final class BiometricAuthenticator: BiometricAuthenticating {
    func authenticate(reason: String) async throws {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

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
