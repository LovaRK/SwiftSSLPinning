import Foundation
import Security

/// The SSLPinningManager orchestrates SSL pinning using a given strategy. 
/// It is defined as an `actor` so its internal state (if any) is thread-safe.
public actor SSLPinningManager {
    private let strategy: PinningStrategy
    private let logger: Logger

    /// Initializes the manager with a pinning strategy and an optional logger.
    /// - Parameters:
    ///   - strategy: The pinning strategy to use (certificate, public key, or SPKI).
    ///   - logger: A `Logger` for output; defaults to `ConsoleLogger`.
    public init(strategy: PinningStrategy, logger: Logger = ConsoleLogger()) {
        self.strategy = strategy
        self.logger = logger
    }

    /// Validates the server trust using the selected pinning strategy.
    /// Throws a `PinningError` if validation fails.
    /// - Parameters:
    ///   - trust: The `SecTrust` object from `URLAuthenticationChallenge`.
    public func validateServerTrust(_ trust: SecTrust) async throws {
        do {
            try strategy.validate(trust: trust)
            logger.logDebug("SSL pinning validation succeeded.")
        } catch {
            logger.logError("SSL pinning validation failed: \(error.localizedDescription)")
            throw error
        }
    }

    /// Handles URLSession authentication challenges for SSL pinning.
    /// Can be called from a custom URLSession delegate.
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        Task {
            do {
                try await self.validateServerTrust(serverTrust)
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            } catch {
                logger.logError("Authentication challenge cancelled: \(error.localizedDescription)")
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
    }
} 