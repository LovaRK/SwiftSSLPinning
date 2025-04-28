import Foundation

/// Simple logging abstraction to allow structured logging (e.g. os_log) instead of print.
public protocol Logger {
    /// Log a debug or informational message.
    func logDebug(_ message: String)
    /// Log an error message.
    func logError(_ message: String)
} 