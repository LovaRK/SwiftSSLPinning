import Foundation

/// A URLSessionDelegate that uses `SSLPinningManager` to evaluate server trust challenges.
/// This separates delegate logic from networking code and allows injecting a mock manager for testing.
public class SSLPinningDelegate: NSObject, URLSessionDelegate {
    private let pinningManager: SSLPinningManager
    private let logger: Logger

    /// - Parameters:
    ///   - pinningManager: The `SSLPinningManager` instance to use for trust evaluation.
    ///   - logger: A logger for errors; defaults to `ConsoleLogger`.
    public init(pinningManager: SSLPinningManager, logger: Logger = ConsoleLogger()) {
        self.pinningManager = pinningManager
        self.logger = logger
    }

    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        // Perform SSL pinning asynchronously to avoid blocking.
        Task {
            do {
                try await pinningManager.validateServerTrust(serverTrust)
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            } catch {
                logger.logError("Authentication challenge cancelled: \(error.localizedDescription)")
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
    }
} 