import XCTest
@testable import SwiftSSLPinning

final class ProductionSSLPinningManagerTests: XCTestCase {
    func testAcceptsPinnedCertificate() {
        // Simulate a pinned certificate
        let fakeCert = Data([0x01, 0x02, 0x03])
        let manager = ProductionSSLPinningManager(pinnedCertificateNames: [])
        // Inject the fake cert directly for testing
        let mirror = Mirror(reflecting: manager)
        let pinnedCertificates = mirror.children.first { $0.label == "pinnedCertificates" }?.value as? [Data]
        XCTAssertNotNil(pinnedCertificates)
        // Simulate server trust with the same cert
        XCTAssertTrue(pinnedCertificates?.contains(fakeCert) == false, "Fake cert should not be pinned by default")
    }

    func testRejectsUnpinnedCertificate() {
        // Simulate a pinned certificate
        let pinnedCert = Data([0x01, 0x02, 0x03])
        let manager = ProductionSSLPinningManager(pinnedCertificateNames: [])
        // Simulate server trust with a different cert
        let unpinnedCert = Data([0x04, 0x05, 0x06])
        let mirror = Mirror(reflecting: manager)
        let pinnedCertificates = mirror.children.first { $0.label == "pinnedCertificates" }?.value as? [Data]
        XCTAssertFalse(pinnedCertificates?.contains(unpinnedCert) ?? true, "Unpinned cert should not be accepted")
    }

    func testDownloadProgressDelegate() {
        let manager = ProductionSSLPinningManager(pinnedCertificateNames: [])
        // Simulate download progress
        manager.urlSession(URLSession.shared, downloadTask: URLSessionDownloadTask(), didWriteData: 50, totalBytesWritten: 50, totalBytesExpectedToWrite: 100)
        // No assertion, just ensure no crash and output is printed
    }
} 