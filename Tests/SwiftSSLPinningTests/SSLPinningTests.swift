import XCTest
@testable import SwiftSSLPinning

final class SSLPinningTests: XCTestCase {
    func testBasicFunctionality() async {
        // Test logger
        let logger = ConsoleLogger()
        logger.logDebug("Test debug message")
        logger.logError("Test error message")
        
        // Test hasher
        let hasher = SHA256HashingService()
        let testData = Data("test".utf8)
        let hash = hasher.sha256(testData)
        XCTAssertFalse(hash.isEmpty)
        
        // Test error types
        let pinningError = PinningError.certificateMismatch
        XCTAssertNotNil(pinningError.errorDescription)
        XCTAssertEqual(pinningError.errorDescription, "Certificate does not match the pinned certificate.")
        
        // Test strategy creation
        let certData = Data("test certificate".utf8)
        let certStrategy = CertificatePinningStrategy(certificateData: certData)
        XCTAssertNotNil(certStrategy)
        
        let keyHashes = [Data("test key hash".utf8)]
        let keyStrategy = PublicKeyPinningStrategy(pinnedKeyHashes: keyHashes, hasher: hasher)
        XCTAssertNotNil(keyStrategy)
        
        let spkiHashes = [Data("test spki hash".utf8)]
        let spkiStrategy = SPKIPinningStrategy(pinnedSPKIHashes: spkiHashes, hasher: hasher)
        XCTAssertNotNil(spkiStrategy)
        
        // Test manager creation
        let manager = SSLPinningManager(strategy: certStrategy)
        XCTAssertNotNil(manager)
    }
} 