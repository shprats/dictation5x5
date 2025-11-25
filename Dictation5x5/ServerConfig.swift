//
//  ServerConfig.swift
//  Dictation5x5
//
//  Server configuration management for WebSocket speech server
//

import Foundation

/// Manages WebSocket server URL configuration with persistence
final class ServerConfig: ObservableObject {
    @Published var serverURL: URL {
        didSet {
            save()
        }
    }
    
    private let userDefaultsKey = "dictation5x5.serverURL"
    
    init() {
        // Default to localhost for development, or use saved value
        if let saved = UserDefaults.standard.string(forKey: userDefaultsKey),
           let url = URL(string: saved) {
            self.serverURL = url
        } else {
            // Default: localhost for local development
            // Change to your Cloud Run URL for production
            self.serverURL = URL(string: "ws://localhost:8080")!
        }
    }
    
    private func save() {
        UserDefaults.standard.set(serverURL.absoluteString, forKey: userDefaultsKey)
    }
    
    /// Convenience method to set server URL from string
    func setURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        serverURL = url
        return true
    }
    
    /// Get default Cloud Run URL (for reference)
    static var defaultCloudRunURL: URL {
        URL(string: "wss://websocket-speech-server-103108986027.us-central1.run.app")!
    }
}

