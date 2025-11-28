//
//  UserProfileView.swift
//  Dictation5x5
//
//  User profile and account management view
//

import SwiftUI

struct UserProfileView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var showSignOutConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    @State private var isDeletingAccount = false
    
    var body: some View {
        NavigationView {
            Form {
                // User Info Section
                Section(header: Text("Account")) {
                    if let user = authManager.currentUser {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email ?? "No email")
                                .foregroundColor(.secondary)
                        }
                        
                        if let displayName = user.displayName {
                            HStack {
                                Text("Name")
                                Spacer()
                                Text(displayName)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("User ID")
                            Spacer()
                            Text(user.uid.prefix(8) + "...")
                                .foregroundColor(.secondary)
                                .font(.system(.caption, design: .monospaced))
                        }
                    }
                }
                
                // Account Actions Section
                Section(header: Text("Actions")) {
                    Button(action: {
                        showSignOutConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Sign Out")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        showDeleteAccountConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Account")
                        }
                        .foregroundColor(.red)
                    }
                    .disabled(isDeletingAccount)
                }
                
                // Legal & Support Section
                Section(header: Text("Legal & Support")) {
                    Link(destination: URL(string: "https://yourwebsite.com/privacy-policy")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://yourwebsite.com/terms")!) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://yourwebsite.com/support")!) {
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
                
                // App Info Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
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
            .alert("Delete Account", isPresented: $showDeleteAccountConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("This action cannot be undone. All your data will be permanently deleted. Are you sure you want to delete your account?")
            }
        }
    }
    
    private func deleteAccount() {
        isDeletingAccount = true
        
        Task {
            do {
                try await authManager.deleteAccount()
                await MainActor.run {
                    isDeletingAccount = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isDeletingAccount = false
                    // Error will be shown via AuthManager state
                }
            }
        }
    }
}

