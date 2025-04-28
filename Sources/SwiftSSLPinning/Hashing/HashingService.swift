import Foundation
import CryptoKit

/// Protocol for hashing data. Abstracts hashing so it can be mocked in tests.
public protocol HashingService {
    /// Computes a SHA-256 hash of the given data.
    func sha256(_ data: Data) -> Data
} 