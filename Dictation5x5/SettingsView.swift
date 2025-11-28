//
//  SettingsView.swift
//  Dictation5x5
//
//  Settings view for configuring server URL and other options
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var serverConfig: ServerConfig
    @ObservedObject var streaming: SpeechStreamingManager
    @Environment(\.dismiss) var dismiss
    
    @State private var serverURLString: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showUserProfile = false
    @State private var showSignOutConfirmation = false
    
    // Preset URLs
    private let presets = [
        ("Local Development", "ws://localhost:8080"),
        ("Cloud Run (Default)", "wss://websocket-speech-server-103108986027.us-central1.run.app"),
        ("Custom", "")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                // Note Organization Section - FIRST
                Section(header: Text("Note Organization")) {
                    NavigationLink(destination: SpecialtyConfigView(profileConfig: UserProfileConfig.shared)) {
                        HStack {
                            Image(systemName: UserProfileConfig.shared.selectedSpecialty.icon)
                                .foregroundColor(.brandBlue)
                                .frame(width: 30)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Medical Specialty")
                                    .font(.headline)
                                Text(UserProfileConfig.shared.selectedSpecialty.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // User Account Section
                Section(header: Text("Account")) {
                    if let user = authManager.currentUser {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.displayName ?? "User")
                                    .font(.headline)
                                Text(user.email ?? "No email")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                showUserProfile = true
                            }) {
                                Image(systemName: "person.circle")
                                    .font(.title2)
                                    .foregroundColor(.brandOrange)
                            }
                        }
                    }
                }
                
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
                                            .foregroundColor(.brandOrange)
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
                            .foregroundColor(.brandOrange)
                    }
                }
                
                Section {
                    Button(action: saveURL) {
                        HStack {
                            Spacer()
                            Text("Save")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(streaming.state != .idle || serverURLString.isEmpty ? Color.gray : Color.brandOrange)
                        .cornerRadius(10)
                    }
                    .disabled(streaming.state != .idle || serverURLString.isEmpty)
                }
                
                // Legal & Support Section
                Section(header: Text("Legal & Support")) {
                    if let privacyURL = AppConfig.privacyPolicyURLValue {
                        Link(destination: privacyURL) {
                            HStack {
                                Image(systemName: "hand.raised")
                                Text("Privacy Policy")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if let termsURL = AppConfig.termsOfServiceURLValue {
                        Link(destination: termsURL) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Terms of Service")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if let supportURL = AppConfig.supportURLValue {
                        Link(destination: supportURL) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                Text("Support")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Account Actions Section
                Section(header: Text("Account Actions")) {
                    Button(action: {
                        showSignOutConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Sign Out")
                            Spacer()
                        }
                        .foregroundColor(.brandBlue)
                    }
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
            .alert("Sign Out", isPresented: $showSignOutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authManager.signOut()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .sheet(isPresented: $showUserProfile) {
                UserProfileView(authManager: authManager)
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
            return .successGreen
        case .connecting, .configuring, .stopping:
            return .brandOrange
        case .streaming:
            return .brandBlue
        case .error:
            return .errorRed
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

