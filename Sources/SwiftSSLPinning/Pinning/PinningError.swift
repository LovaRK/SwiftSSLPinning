import Foundation

/// Errors that can occur during SSL pinning validation.
public enum PinningError: Error, LocalizedError {
    /// No server trust information was available in the challenge.
    case noServerTrust
    /// No certificate was presented by the server.
    case noServerCertificate
    /// Public key of the server did not match any expected pinned key.
    case publicKeyMismatch
    /// Certificate did not match the pinned certificate.
    case certificateMismatch
    /// SPKI hash did not match any expected pinned hash.
    case spkiMismatch
    /// General pinning failure.
    case pinningFailed(reason: String)
    
    public var errorDescription: String? {
        switch self {
        case .noServerTrust:
            return "No server trust available for SSL pinning."
        case .noServerCertificate:
            return "Server did not provide a certificate for SSL pinning."
        case .publicKeyMismatch:
            return "Public key does not match any pinned key."
        case .certificateMismatch:
            return "Certificate does not match the pinned certificate."
        case .spkiMismatch:
            return "SPKI hash does not match any pinned SPKI."
        case .pinningFailed(let reason):
            return "SSL pinning failed: \(reason)"
        }
    }
} 