//
//  LoginView.swift
//  Dictation5x5
//
//  Authentication view with Sign in with Apple, Google, and Email/Password options
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var authManager: AuthManager
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var showForgotPassword = false
    @State private var forgotPasswordEmail = ""
    @State private var showForgotPasswordAlert = false
    @State private var forgotPasswordMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Logo/Title
                VStack(spacing: 8) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.brandOrange)
                    
                    Text("Dictation5x5")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.brandBlue)
                    
                    Text("Medical Dictation Made Easy")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // Sign in with Apple
                Button(action: {
                    authManager.signInWithApple()
                }) {
                    HStack {
                        Image(systemName: "applelogo")
                            .font(.title3)
                        Text("Continue with Apple")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(8)
                }
                
                // Sign in with Google
                Button(action: {
                    authManager.signInWithGoogle()
                }) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.title3)
                        Text("Continue with Google")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(Color(red: 0.26, green: 0.52, blue: 0.96))
                    .cornerRadius(8)
                }
                
                // Divider
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    Text("OR")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.vertical, 8)
                
                // Email/Password Form
                VStack(spacing: 16) {
                    if isSignUp {
                        TextField("Display Name (Optional)", text: $displayName)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.name)
                            .autocapitalization(.words)
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(isSignUp ? .newPassword : .password)
                    
                    if !isSignUp {
                        Button("Forgot Password?") {
                            showForgotPassword = true
                        }
                        .font(.caption)
                        .foregroundColor(.brandBlue)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    Button(action: {
                        if isSignUp {
                            authManager.signUpWithEmail(email: email, password: password, displayName: displayName.isEmpty ? nil : displayName)
                        } else {
                            authManager.signInWithEmail(email: email, password: password)
                        }
                    }) {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.white)
                            .background(email.isEmpty || password.isEmpty ? Color.gray : Color.brandOrange)
                            .cornerRadius(12)
                    }
                    .disabled(email.isEmpty || password.isEmpty || authManager.state == .signingIn)
                    
                    // Toggle between Sign In and Sign Up
                    Button(action: {
                        isSignUp.toggle()
                        password = ""
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.caption)
                            .foregroundColor(.brandBlue)
                    }
                }
                
                // Error Message
                if case .error(let message) = authManager.state {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.errorRed)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
                
                // Loading Indicator
                if authManager.state == .signingIn {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(
                email: $forgotPasswordEmail,
                onSend: {
                    Task {
                        do {
                            try await authManager.resetPassword(email: forgotPasswordEmail)
                            forgotPasswordMessage = "Password reset email sent. Please check your inbox."
                            showForgotPasswordAlert = true
                            showForgotPassword = false
                        } catch {
                            forgotPasswordMessage = "Failed to send reset email: \(error.localizedDescription)"
                            showForgotPasswordAlert = true
                        }
                    }
                }
            )
        }
        .alert("Password Reset", isPresented: $showForgotPasswordAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(forgotPasswordMessage)
        }
    }
}

struct ForgotPasswordView: View {
    @Binding var email: String
    let onSend: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                
                Button(action: {
                    onSend()
                }) {
                    Text("Send Reset Link")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(email.isEmpty ? Color.gray : Color.brandOrange)
                        .cornerRadius(12)
                }
                .disabled(email.isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

