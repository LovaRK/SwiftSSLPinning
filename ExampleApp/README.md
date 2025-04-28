# SwiftSSLPinning Example App

This example app demonstrates how to implement SSL certificate pinning in a real-world iOS application using the SwiftSSLPinning package.

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/LovaRK/SwiftSSLPinning.git
   cd SwiftSSLPinning
   ```

2. Open the ExampleApp in Xcode:
   ```bash
   open ExampleApp/ExampleApp.xcodeproj
   ```

3. Add your SSL certificate:
   - Export your server's SSL certificate:
     ```bash
     openssl s_client -servername api.example.com -connect api.example.com:443 < /dev/null | openssl x509 -outform DER -out api.example.com.cer
     ```
   - Drag the .cer file into the ExampleApp target in Xcode
   - Make sure "Copy items if needed" is checked
   - Add to your target
   - Verify the certificate is included in "Copy Bundle Resources" in Build Phases

4. Update the API endpoint:
   - Open `NetworkManager.swift`
   - Replace `https://api.example.com/data` with your actual API endpoint

## Features Demonstrated

1. Certificate Loading
   - Loading certificate from bundle
   - Error handling for missing certificates

2. Network Layer
   - SSL pinning implementation
   - Proper error handling
   - Logging

3. UI Integration
   - Loading states
   - Error display
   - Success handling

## Testing

1. Test with valid certificate:
   - Use your actual server certificate
   - Verify successful API calls

2. Test with invalid certificate:
   - Replace the certificate with an invalid one
   - Verify proper error handling

## Best Practices Shown

1. Error Handling
   - Specific error types
   - User-friendly error messages
   - Proper logging

2. UI Feedback
   - Loading indicators
   - Status updates
   - Error display

3. Code Organization
   - Separation of concerns
   - Clean architecture
   - Proper dependency injection

## Troubleshooting

1. Certificate Issues
   - Verify certificate format (DER)
   - Check certificate expiration
   - Ensure proper bundle inclusion

2. Network Issues
   - Check API endpoint
   - Verify server certificate
   - Check network connectivity

3. Build Issues
   - Clean build folder
   - Update package dependencies
   - Check deployment target 