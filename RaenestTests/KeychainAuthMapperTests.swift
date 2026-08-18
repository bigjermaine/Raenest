import Security
import XCTest
@testable import Raenest

final class KeychainAuthMapperTests: XCTestCase {
    func testMapsUserCancelToBiometricCancelled() {
        XCTAssertEqual(KeychainAuthMapper.sendMoneyError(from: errSecUserCanceled), .biometricCancelled)
    }

    func testMapsAuthFailureToBiometricFailed() {
        XCTAssertEqual(KeychainAuthMapper.sendMoneyError(from: errSecAuthFailed), .biometricFailed)
    }

    func testMapsMissingItemToTokenUnavailable() {
        XCTAssertEqual(KeychainAuthMapper.sendMoneyError(from: errSecItemNotFound), .tokenUnavailable)
        XCTAssertEqual(
            KeychainAuthMapper.sendMoneyError(from: KeychainStoreError.itemNotFound),
            .tokenUnavailable
        )
    }
}
