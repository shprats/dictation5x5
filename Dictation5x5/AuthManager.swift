//
//  AuthManager.swift
//  Dictation5x5
//
//  Created by pratik on 9/14/25.
//


import Foundation
import AuthenticationServices
import Combine

/// Replace stubs with real Firebase / Sign in with Apple / Google logic.
final class AuthManager: ObservableObject {

    enum AuthState {
        case signedOut
        case signingIn
        case signedIn(userID: String, email: String?)
        case error(String)
    }

    @Published private(set) var state: AuthState = .signedOut

    func signInWithApple() {
        // Placeholder: integrate ASAuthorizationController
        state = .signingIn
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.state = .signedIn(userID: "apple-user-123", email: "user@example.com")
        }
    }

    func signInWithGoogle() {
        state = .signingIn
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.state = .signedIn(userID: "google-user-789", email: "guser@example.com")
        }
    }

    func signInWithEmail(email: String, password: String) {
        state = .signingIn
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if password.count >= 4 {
                self.state = .signedIn(userID: "email-\(UUID().uuidString.prefix(6))", email: email)
            } else {
                self.state = .error("Invalid credentials (stub)")
            }
        }
    }

    func signOut() {
        state = .signedOut
    }
}