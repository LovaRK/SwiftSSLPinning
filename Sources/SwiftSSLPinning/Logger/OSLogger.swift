import Foundation
import OSLog

/// A logger using Apple's unified logging system (OSLog).
/// This provides structured, level-based logging instead of raw prints.
public final class OSLogger: Logger {
    private let logger: OSLog
    
    public init(subsystem: String = Bundle.main.bundleIdentifier ?? "App", category: String) {
        self.logger = OSLog(subsystem: subsystem, category: category)
    }
    
    public func logDebug(_ message: String) {
        os_log("%{public}@", log: logger, type: .debug, message)
    }
    
    public func logError(_ message: String) {
        os_log("%{public}@", log: logger, type: .error, message)
    }
} 