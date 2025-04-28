import Foundation
import SwiftSSLPinning

class NetworkManager {
    private let session: URLSession
    private let pinningManager: SSLPinningManager
    private let logger: OSLogger
    
    init() throws {
        // Initialize logger
        logger = OSLogger(subsystem: "com.example.app", category: "Networking")
        
        // Load certificate
        guard let certificateURL = Bundle.main.url(forResource: "api.example.com", withExtension: "cer"),
              let certificateData = try? Data(contentsOf: certificateURL) else {
            logger.error("Failed to load certificate")
            throw PinningError.certificateNotFound
        }
        
        // Create pinning strategy
        let strategy = CertificatePinningStrategy(certificateData: certificateData)
        
        // Create pinning manager
        pinningManager = SSLPinningManager(strategy: strategy, logger: logger)
        
        // Create URLSession with pinning delegate
        let delegate = SSLPinningDelegate(pinningManager: pinningManager)
        session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
    }
    
    func fetchData() async throws -> Data {
        let url = URL(string: "https://api.example.com/data")!
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw PinningError.invalidResponse
            }
            
            return data
        } catch let error as PinningError {
            // Handle specific pinning errors
            switch error {
            case .certificateMismatch:
                logger.error("Certificate mismatch detected!")
            case .publicKeyMismatch:
                logger.error("Public key mismatch detected!")
            default:
                logger.error("Pinning error: \(error)")
            }
            throw error
        }
    }
} 