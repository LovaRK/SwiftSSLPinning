import Foundation

/// A basic console logger for development. In production, use OSLog or a more advanced logger.
public final class ConsoleLogger: Logger {
    public init() {}
    
    public func logDebug(_ message: String) {
        print("DEBUG: \(message)")
    }
    
    public func logError(_ message: String) {
        print("ERROR: \(message)")
    }
} 