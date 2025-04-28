import Foundation
import Security

/// Protocol for an SSL pinning strategy (certificate, public key, SPKI, etc.).
/// Each strategy validates server trust and throws if validation fails.
public protocol PinningStrategy {
    /// Validates the given `SecTrust`. Throws a `PinningError` if validation fails.
    /// - Parameters:
    ///   - trust: The `SecTrust` object from the server challenge.
    func validate(trust: SecTrust) throws
} 