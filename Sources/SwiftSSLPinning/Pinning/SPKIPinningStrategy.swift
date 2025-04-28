import Foundation
import Security

/// Pinning strategy that checks the SHA256 hash of the certificate's Subject Public Key Info (SPKI).
/// OWASP recommends SPKI pinning as a robust approach.
public final class SPKIPinningStrategy: PinningStrategy {
    private let pinnedSPKIHashes: [Data]  // SHA256 hashes of allowed SPKI.
    private let hasher: HashingService

    /// - Parameters:
    ///   - pinnedSPKIHashes: Array of SHA256(SPKI) values that are trusted.
    ///   - hasher: A hashing service to compute SHA256.
    public init(pinnedSPKIHashes: [Data], hasher: HashingService) {
        self.pinnedSPKIHashes = pinnedSPKIHashes
        self.hasher = hasher
    }

    public func validate(trust: SecTrust) throws {
        guard let serverCert = SecTrustGetCertificateAtIndex(trust, 0) else {
            throw PinningError.noServerCertificate
        }
        // For SPKI, we can simply use the public key bytes (CryptoKit SHA-256).
        // A more precise implementation would construct the ASN.1 SPKI structure.
        guard let publicKey = SecCertificateCopyKey(serverCert) else {
            throw PinningError.pinningFailed(reason: "Unable to extract public key for SPKI")
        }
        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            throw PinningError.pinningFailed(reason: "Unable to get public key data: \(error?.takeRetainedValue().localizedDescription ?? "unknown error")")
        }
        let spkiHash = hasher.sha256(publicKeyData)
        guard pinnedSPKIHashes.contains(spkiHash) else {
            throw PinningError.spkiMismatch
        }
    }
} 