# SwiftSSLPinning

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A robust, protocol-oriented Swift package for implementing SSL certificate pinning in iOS and macOS applications. This package follows Clean Architecture principles and provides multiple pinning strategies with strong type safety and concurrency support.

## Features

- Multiple pinning strategies:
  - Certificate pinning
  - Public key pinning
  - SPKI (Subject Public Key Info) pinning
- Thread-safe implementation using Swift actors
- Protocol-oriented design for easy testing and mocking
- Configurable logging (Console or OSLog)
- Comprehensive error handling
- Support for iOS 13+ and macOS 10.15+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/LovaRK/SwiftSSLPinning.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File > Swift Packages > Add Package Dependency
2. Enter the repository URL
3. Select the version you want to use

## Usage

### Basic Certificate Pinning

```swift
import SwiftSSLPinning

// Load your certificate from the app bundle
guard let certificateURL = Bundle.main.url(forResource: "your-certificate", withExtension: "cer"),
      let certificateData = try? Data(contentsOf: certificateURL) else {
    fatalError("Failed to load certificate")
}

// Create a certificate pinning strategy
let strategy = CertificatePinningStrategy(certificateData: certificateData)

// Create the pinning manager
let manager = SSLPinningManager(strategy: strategy)

// Create a URLSession with the pinning delegate
let delegate = SSLPinningDelegate(pinningManager: manager)
let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)

// Use the session for network requests
let task = session.dataTask(with: URL(string: "https://api.example.com")!) { data, response, error in
    // Handle response
}
task.resume()
```

### Public Key Pinning

```swift
import SwiftSSLPinning

// Your pre-computed public key hashes
let keyHashes: [Data] = // ... your SHA256 hashes of public keys

// Create a public key pinning strategy
let hasher = SHA256HashingService()
let strategy = PublicKeyPinningStrategy(pinnedKeyHashes: keyHashes, hasher: hasher)

// Create and use the manager as shown above
```

### Custom Logging

```swift
import SwiftSSLPinning

// Create a custom logger
let logger = OSLogger(subsystem: "com.yourapp", category: "Networking")

// Use it with the manager
let manager = SSLPinningManager(strategy: strategy, logger: logger)
```

## Error Handling

The package provides detailed error types through `PinningError`:

```swift
do {
    try await manager.validateServerTrust(serverTrust)
} catch PinningError.certificateMismatch {
    // Handle certificate mismatch
} catch PinningError.publicKeyMismatch {
    // Handle public key mismatch
} catch {
    // Handle other errors
}
```

## Testing

The package is designed for easy testing through protocol abstractions. You can mock the `PinningStrategy`, `Logger`, and `HashingService` for your tests.

## Real-World Example

Here's a step-by-step guide to implement SSL pinning in your app:

### 1. Prepare Your Certificate

1. Export your server's SSL certificate:
   ```bash
   openssl s_client -servername api.example.com -connect api.example.com:443 < /dev/null | openssl x509 -outform DER -out api.example.com.cer
   ```

2. Add the certificate to your Xcode project:
   - Drag the .cer file into your Xcode project
   - Make sure "Copy items if needed" is checked
   - Add to your target
   - Verify the certificate is included in "Copy Bundle Resources" in Build Phases

### 2. Create a Network Layer

```swift
import SwiftSSLPinning
import Foundation

class NetworkManager {
    private let session: URLSession
    private let pinningManager: SSLPinningManager
    
    init() throws {
        // 1. Load certificate
        guard let certificateURL = Bundle.main.url(forResource: "api.example.com", withExtension: "cer"),
              let certificateData = try? Data(contentsOf: certificateURL) else {
            throw PinningError.certificateNotFound
        }
        
        // 2. Create pinning strategy
        let strategy = CertificatePinningStrategy(certificateData: certificateData)
        
        // 3. Create pinning manager with logging
        let logger = OSLogger(subsystem: "com.yourapp", category: "Networking")
        pinningManager = SSLPinningManager(strategy: strategy, logger: logger)
        
        // 4. Create URLSession with pinning delegate
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
                // Handle certificate mismatch (potential security breach)
                logger.error("Certificate mismatch detected!")
            case .publicKeyMismatch:
                // Handle public key mismatch
                logger.error("Public key mismatch detected!")
            default:
                // Handle other pinning errors
                logger.error("Pinning error: \(error)")
            }
            throw error
        }
    }
}
```

### 3. Usage in Your App

```swift
class YourViewController: UIViewController {
    private var networkManager: NetworkManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            networkManager = try NetworkManager()
        } catch {
            // Handle initialization error
            showError("Failed to initialize network manager: \(error)")
        }
    }
    
    func fetchData() {
        Task {
            do {
                let data = try await networkManager?.fetchData()
                // Handle successful response
                updateUI(with: data)
            } catch {
                // Handle error
                showError("Failed to fetch data: \(error)")
            }
        }
    }
}
```

### 4. Testing Your Implementation

1. Test with valid certificate:
   ```swift
   func testValidCertificate() async throws {
       let manager = try NetworkManager()
       let data = try await manager.fetchData()
       XCTAssertNotNil(data)
   }
   ```

2. Test with invalid certificate:
   ```swift
   func testInvalidCertificate() async {
       // Replace certificate with invalid one
       let manager = try? NetworkManager()
       do {
           _ = try await manager?.fetchData()
           XCTFail("Should throw certificate mismatch error")
       } catch PinningError.certificateMismatch {
           // Expected error
       }
   }
   ```

### 5. Best Practices

1. **Certificate Management**:
   - Keep certificates up to date
   - Implement certificate rotation strategy
   - Store certificates securely
   - Consider using multiple certificates for different environments

2. **Error Handling**:
   - Log all pinning failures
   - Implement proper error recovery
   - Consider fallback strategies
   - Monitor for security breaches

3. **Testing**:
   - Test with valid and invalid certificates
   - Test certificate rotation
   - Test error scenarios
   - Use mock certificates in development

4. **Security**:
   - Never disable pinning in production
   - Monitor for certificate changes
   - Implement proper logging
   - Consider using multiple pinning strategies

## License

This package is available under the MIT license. See the LICENSE file for more info. 