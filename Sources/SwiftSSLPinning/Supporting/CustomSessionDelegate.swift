import Foundation

/// A sample delegate that combines SSL pinning with download progress tracking.
public class CustomSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    private let pinningManager: SSLPinningManager

    public init(pinningManager: SSLPinningManager) {
        self.pinningManager = pinningManager
    }

    // SSL pinning
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        Task {
            await pinningManager.urlSession(session, didReceive: challenge, completionHandler: completionHandler)
        }
    }

    // Download progress
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        print("Download progress: \(progress * 100)%")
    }

    // Optionally, handle download completion
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download finished: \(location)")
    }
} 