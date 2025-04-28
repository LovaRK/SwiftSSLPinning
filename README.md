# SwiftSSLPinning

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
    .package(url: "https://github.com/yourusername/SwiftSSLPinning.git", from: "1.0.0")
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

// Load your certificate data
let certData: Data = // ... load your .cer file

// Create a certificate pinning strategy
let strategy = CertificatePinningStrategy(certificateData: certData)

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

## License

This package is available under the MIT license. See the LICENSE file for more info. 