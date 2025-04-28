import Foundation
import Security

/// Handles SSL pinning using one or more pinned certificates.
public class ProductionSSLPinningManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    private let pinnedCertificates: [Data]

    /// Initialize with an array of DER-encoded certificate names (without extension).
    public init(pinnedCertificateNames: [String]) {
        self.pinnedCertificates = pinnedCertificateNames.compactMap { name in
            guard let url = Bundle.main.url(forResource: name, withExtension: "cer"),
                  let data = try? Data(contentsOf: url) else { return nil }
            return data
        }
    }

    // MARK: - URLSessionDelegate (SSL Pinning)
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Compare server certificate(s) to pinned
        let serverCertCount = SecTrustGetCertificateCount(serverTrust)
        for i in 0..<serverCertCount {
            guard let serverCert = SecTrustGetCertificateAtIndex(serverTrust, i) else { continue }
            let serverCertData = SecCertificateCopyData(serverCert) as Data
            if pinnedCertificates.contains(serverCertData) {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }
        // No match
        completionHandler(.cancelAuthenticationChallenge, nil)
    }

    // MARK: - URLSessionDownloadDelegate (Progress)
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        print("Download progress: \(progress * 100)%")
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        print("Download finished: \(location)")
    }
} 