import UIKit
import SwiftSSLPinning

class ViewController: UIViewController {
    private var networkManager: NetworkManager?
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let statusLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initializeNetworkManager()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Setup activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Setup status label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        view.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func initializeNetworkManager() {
        do {
            networkManager = try NetworkManager()
            statusLabel.text = "Network manager initialized successfully"
        } catch {
            statusLabel.text = "Failed to initialize network manager: \(error.localizedDescription)"
        }
    }
    
    @objc private func fetchData() {
        guard let networkManager = networkManager else {
            statusLabel.text = "Network manager not initialized"
            return
        }
        
        activityIndicator.startAnimating()
        statusLabel.text = "Fetching data..."
        
        Task {
            do {
                let data = try await networkManager.fetchData()
                // Handle successful response
                if let json = try? JSONSerialization.jsonObject(with: data) {
                    statusLabel.text = "Data received: \(json)"
                } else {
                    statusLabel.text = "Data received but not JSON"
                }
            } catch {
                statusLabel.text = "Error: \(error.localizedDescription)"
            }
            activityIndicator.stopAnimating()
        }
    }
} 