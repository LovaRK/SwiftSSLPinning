import Foundation
import CryptoKit

/// Default SHA-256 hashing service using CryptoKit.
public struct SHA256HashingService: HashingService {
    public init() {}
    
    public func sha256(_ data: Data) -> Data {
        let digest = SHA256.hash(data: data)
        return Data(digest)
    }
} 