import XCTest
import Security
@testable import SwiftSSLPinning

final class SSLPinningTests: XCTestCase {
    func testCertificatePinning() throws {
        // Create mock certificate data
        let mockCertData = Data([1, 2, 3, 4]) // In real tests, use actual certificate data
        let strategy = CertificatePinningStrategy(certificateData: mockCertData)
        
        // Create mock SecTrust
        var trust: SecTrust?
        let status = SecTrustCreateWithCertificates(mockCertData as CFData, nil, &trust)
        XCTAssertEqual(status, errSecSuccess)
        
        // Test validation
        XCTAssertThrowsError(try strategy.validate(trust: trust!)) { error in
            XCTAssertTrue(error is PinningError)
        }
    }
    
    func testPublicKeyPinning() throws {
        // Create mock public key hash
        let mockKeyHash = Data([1, 2, 3, 4]) // In real tests, use actual public key hash
        let hasher = SHA256HashingService()
        let strategy = PublicKeyPinningStrategy(pinnedKeyHashes: [mockKeyHash], hasher: hasher)
        
        // Create mock SecTrust
        var trust: SecTrust?
        let mockCertData = Data([1, 2, 3, 4]) // In real tests, use actual certificate data
        let status = SecTrustCreateWithCertificates(mockCertData as CFData, nil, &trust)
        XCTAssertEqual(status, errSecSuccess)
        
        // Test validation
        XCTAssertThrowsError(try strategy.validate(trust: trust!)) { error in
            XCTAssertTrue(error is PinningError)
        }
    }
    
    func testSSLPinningManager() async throws {
        // Create mock strategy that always succeeds
        class MockStrategy: PinningStrategy {
            func validate(trust: SecTrust) throws {
                // Always succeed
            }
        }
        
        let strategy = MockStrategy()
        let manager = SSLPinningManager(strategy: strategy)
        
        // Create mock SecTrust
        var trust: SecTrust?
        let mockCertData = Data([1, 2, 3, 4])
        let status = SecTrustCreateWithCertificates(mockCertData as CFData, nil, &trust)
        XCTAssertEqual(status, errSecSuccess)
        
        // Test validation
        XCTAssertNoThrow(try await manager.validateServerTrust(trust!))
    }
} 