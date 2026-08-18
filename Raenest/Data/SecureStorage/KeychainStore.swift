import Foundation
import LocalAuthentication
import Security

protocol KeychainStoring {
    func setProtected(_ value: String, for key: String) throws
    func itemExists(_ key: String) -> Bool
    func getProtected(_ key: String, context: LAContext) throws -> String
}

enum KeychainStoreError: Equatable, Error {
    case unexpectedStatus(OSStatus)
    case itemNotFound
    case invalidData
    case accessControlUnavailable
}

enum KeychainAuthMapper {
    static func sendMoneyError(from status: OSStatus) -> SendMoneyError {
        switch status {
        case errSecUserCanceled:
            return .biometricCancelled
        case errSecAuthFailed:
            return .biometricFailed
        case errSecItemNotFound:
            return .tokenUnavailable
        default:
            return .tokenUnavailable
        }
    }

    static func sendMoneyError(from error: Error) -> SendMoneyError {
        if let storeError = error as? KeychainStoreError {
            switch storeError {
            case .itemNotFound, .invalidData, .accessControlUnavailable:
                return .tokenUnavailable
            case .unexpectedStatus(let status):
                return sendMoneyError(from: status)
            }
        }
        return .tokenUnavailable
    }
}

final class KeychainStore: KeychainStoring {
    private let service: String

    init(service: String = "com.jermaine.Raenest") {
        self.service = service
    }

    func setProtected(_ value: String, for key: String) throws {
        let data = Data(value.utf8)
        let query = baseQuery(for: key)
        SecItemDelete(query as CFDictionary)

        var error: Unmanaged<CFError>?
        guard let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.biometryCurrentSet, .or, .devicePasscode],
            &error
        ) else {
            throw KeychainStoreError.accessControlUnavailable
        }

        var item = query
        item[kSecValueData as String] = data
        item[kSecAttrAccessControl as String] = access

        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainStoreError.unexpectedStatus(status)
        }
    }

    func itemExists(_ key: String) -> Bool {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = false
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUIFail

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
            || status == errSecInteractionNotAllowed
            || status == errSecAuthFailed
    }

    func getProtected(_ key: String, context: LAContext) throws -> String {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecUseAuthenticationContext as String] = context
        query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUIFail

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else {
            throw KeychainStoreError.itemNotFound
        }
        guard status == errSecSuccess else {
            throw KeychainStoreError.unexpectedStatus(status)
        }
        guard let data = result as? Data, let value = String(data: data, encoding: .utf8) else {
            throw KeychainStoreError.invalidData
        }
        return value
    }

    private func baseQuery(for key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }
}
