//
//  SettingsView.swift
//  Dictation5x5
//
//  Settings view for configuring server URL and other options
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var serverConfig: ServerConfig
    @ObservedObject var streaming: SpeechStreamingManager
    @Environment(\.dismiss) var dismiss
    
    @State private var serverURLString: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Preset URLs
    private let presets = [
        ("Local Development", "ws://localhost:8080"),
        ("Cloud Run (Default)", "wss://websocket-speech-server-103108986027.us-central1.run.app"),
        ("Custom", "")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Server Configuration")) {
                    Text("WebSocket Server URL")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("ws://localhost:8080", text: $serverURLString)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                    
                    Text("Current: \(serverConfig.serverURL.absoluteString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Quick Presets")) {
                    ForEach(presets, id: \.0) { preset in
                        if !preset.1.isEmpty {
                            Button(action: {
                                serverURLString = preset.1
                            }) {
                                HStack {
                                    Text(preset.0)
                                    Spacer()
                                    if serverConfig.serverURL.absoluteString == preset.1 {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Connection Status")) {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(statusText)
                            .foregroundColor(statusColor)
                    }
                    
                    if streaming.state != .idle {
                        Text("Note: Server URL can only be changed when idle")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Section {
                    Button(action: saveURL) {
                        HStack {
                            Spacer()
                            Text("Save")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(streaming.state != .idle || serverURLString.isEmpty)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Invalid URL", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                serverURLString = serverConfig.serverURL.absoluteString
            }
        }
    }
    
    private var statusText: String {
        switch streaming.state {
        case .idle:
            return "Idle"
        case .connecting:
            return "Connecting..."
        case .configuring:
            return "Configuring..."
        case .streaming:
            return "Streaming"
        case .stopping:
            return "Stopping..."
        case .finished:
            return "Finished"
        case .error(let message):
            return "Error: \(message)"
        }
    }
    
    private var statusColor: Color {
        switch streaming.state {
        case .idle, .finished:
            return .green
        case .connecting, .configuring, .stopping:
            return .orange
        case .streaming:
            return .blue
        case .error:
            return .red
        }
    }
    
    private func saveURL() {
        guard streaming.state == .idle else {
            errorMessage = "Cannot change server URL while recording or connecting"
            showError = true
            return
        }
        
        let trimmed = serverURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "URL cannot be empty"
            showError = true
            return
        }
        
        // Validate URL format
        guard trimmed.hasPrefix("ws://") || trimmed.hasPrefix("wss://") else {
            errorMessage = "URL must start with ws:// or wss://"
            showError = true
            return
        }
        
        if serverConfig.setURL(trimmed) {
            dismiss()
        } else {
            errorMessage = "Invalid URL format"
            showError = true
        }
    }
}

