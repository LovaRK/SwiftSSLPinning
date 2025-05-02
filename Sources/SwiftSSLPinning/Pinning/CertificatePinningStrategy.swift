import Foundation
import Security

/// Which certificate(s) in the chain to pin against.
public enum CertificatePinningScope {
    case leaf
    case root
    case intermediates
    case any // Accept if any cert in the chain matches
}

/// Pinning strategy that checks the certificate(s) in the chain against pinned certificate(s).
public final class CertificatePinningStrategy: PinningStrategy {
    private let pinnedCertData: [Data]
    private let scope: CertificatePinningScope

    /// - Parameters:
    ///   - certificateData: DER-encoded certificate data(s) bundled with the app.
    ///   - scope: Which certificate(s) in the chain to pin against.
    public init(certificateData: [Data], scope: CertificatePinningScope = .leaf) {
        self.pinnedCertData = certificateData
        self.scope = scope
    }

    public func validate(trust: SecTrust) throws {
        let certCount = SecTrustGetCertificateCount(trust)
        switch scope {
        case .leaf:
            guard let serverCert = SecTrustGetCertificateAtIndex(trust, 0) else {
                throw PinningError.noServerCertificate
            }
            let serverCertData = SecCertificateCopyData(serverCert) as Data
            guard pinnedCertData.contains(serverCertData) else {
                throw PinningError.certificateMismatch
            }
        case .root:
            guard let serverCert = SecTrustGetCertificateAtIndex(trust, certCount - 1) else {
                throw PinningError.noServerCertificate
            }
            let serverCertData = SecCertificateCopyData(serverCert) as Data
            guard pinnedCertData.contains(serverCertData) else {
                throw PinningError.certificateMismatch
            }
        case .intermediates:
            if certCount <= 2 {
                throw PinningError.pinningFailed(reason: "No intermediate certificates in chain")
            }
            var found = false
            for i in 1..<(certCount - 1) {
                guard let serverCert = SecTrustGetCertificateAtIndex(trust, i) else { continue }
                let serverCertData = SecCertificateCopyData(serverCert) as Data
                if pinnedCertData.contains(serverCertData) {
                    found = true
                    break
                }
            }
            if !found {
                throw PinningError.certificateMismatch
            }
        case .any:
            var found = false
            for i in 0..<certCount {
                guard let serverCert = SecTrustGetCertificateAtIndex(trust, i) else { continue }
                let serverCertData = SecCertificateCopyData(serverCert) as Data
                if pinnedCertData.contains(serverCertData) {
                    found = true
                    break
                }
            }
            if !found {
                throw PinningError.certificateMismatch
            }
        }
        // Optionally: SecTrustEvaluateWithError(trust, nil)
    }
}