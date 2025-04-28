import Foundation
import Security

/// Pinning strategy that checks the SHA256 hash of the server's public key against pinned hashes.
/// Public key pinning is more flexible across certificate rotations.
public final class PublicKeyPinningStrategy: PinningStrategy {
    private let pinnedKeyHashes: [Data]  // SHA256 hashes of allowed public keys.
    private let hasher: HashingService

    /// - Parameters:
    ///   - pinnedKeyHashes: Array of SHA256(public key) values (as Data) that are trusted.
    ///   - hasher: A hashing service to compute SHA256.
    public init(pinnedKeyHashes: [Data], hasher: HashingService) {
        self.pinnedKeyHashes = pinnedKeyHashes
        self.hasher = hasher
    }

    public func validate(trust: SecTrust) throws {
        guard let serverCert = SecTrustGetCertificateAtIndex(trust, 0) else {
            throw PinningError.noServerCertificate
        }
        // Extract the public key from the certificate
        guard let publicKey = SecCertificateCopyKey(serverCert) else {
            throw PinningError.pinningFailed(reason: "Unable to extract public key")
        }
        // External representation of the key (X.509 SubjectPublicKeyInfo)
        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            throw PinningError.pinningFailed(reason: "Unable to get public key data: \(error?.takeRetainedValue().localizedDescription ?? "unknown error")")
        }
        let pubKeyHash = hasher.sha256(publicKeyData)
        guard pinnedKeyHashes.contains(pubKeyHash) else {
            throw PinningError.publicKeyMismatch
        }
    }
} 