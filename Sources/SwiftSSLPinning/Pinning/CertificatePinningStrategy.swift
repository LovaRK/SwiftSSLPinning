import Foundation
import Security

/// Pinning strategy that checks the exact leaf certificate against a pinned certificate.
/// Certificate pinning requires app updates if the server certificate changes.
public final class CertificatePinningStrategy: PinningStrategy {
    private let pinnedCertData: Data

    /// - Parameter certificateData: DER-encoded certificate data that was bundled with the app.
    public init(certificateData: Data) {
        self.pinnedCertData = certificateData
    }

    public func validate(trust: SecTrust) throws {
        guard let serverCert = SecTrustGetCertificateAtIndex(trust, 0) else {
            throw PinningError.noServerCertificate
        }
        let serverCertData = SecCertificateCopyData(serverCert) as Data
        guard serverCertData == pinnedCertData else {
            throw PinningError.certificateMismatch
        }
        // If needed, one could also call SecTrustEvaluateWithError(trust, nil) here to ensure validity.
    }
} 