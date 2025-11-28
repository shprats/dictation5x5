//
//  AuthManager.swift
//  Dictation5x5
//
//  Created by pratik on 9/14/25.
//

import Foundation
import AuthenticationServices
import Combine
import CryptoKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

/// Manages user authentication using Firebase Authentication
/// Supports: Sign in with Apple, Google Sign-In, and Email/Password
final class AuthManager: NSObject, ObservableObject {
    
    enum AuthState: Equatable {
        case signedOut
        case signingIn
        case signedIn(userID: String, email: String?, displayName: String?)
        case error(String)
    }
    
    @Published private(set) var state: AuthState = .signedOut
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    
    override init() {
        super.init()
        // Ensure Firebase is configured before setting up listener
        if FirebaseApp.app() == nil {
            // Try to configure Firebase, but handle errors gracefully
            do {
                FirebaseApp.configure()
            } catch {
                // If configuration fails, we'll handle it when auth is actually used
                print("[AuthManager] Warning: Firebase configuration may have failed")
            }
        }
        // Delay listener setup slightly to ensure Firebase is ready
        DispatchQueue.main.async { [weak self] in
            self?.setupAuthListener()
        }
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Auth State Listener
    
    private func setupAuthListener() {
        // Check if Firebase is configured
        guard FirebaseApp.app() != nil else {
            print("[AuthManager] Error: Firebase not configured. Please check GoogleService-Info.plist")
            state = .error("Firebase not configured. Please check GoogleService-Info.plist")
            return
        }
        
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.state = .signedIn(
                        userID: user.uid,
                        email: user.email,
                        displayName: user.displayName
                    )
                } else {
                    self?.state = .signedOut
                }
            }
        }
    }
    
    // MARK: - Sign in with Apple
    
    func signInWithApple() {
        state = .signingIn
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - Sign in with Google
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            state = .error("Firebase configuration error. Please check GoogleService-Info.plist")
            return
        }
        
        state = .signingIn
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let presentingViewController = windowScene.windows.first?.rootViewController else {
            state = .error("Unable to find presenting view controller")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.state = .error("Google Sign-In failed: \(error.localizedDescription)")
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    self?.state = .error("Failed to get Google ID token")
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self?.state = .error("Firebase authentication failed: \(error.localizedDescription)")
                        } else if authResult?.user != nil {
                            // State will be updated by auth listener
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Email/Password Authentication
    
    func signInWithEmail(email: String, password: String) {
        state = .signingIn
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.state = .error("Sign in failed: \(error.localizedDescription)")
                } else if result?.user != nil {
                    // State will be updated by auth listener
                }
            }
        }
    }
    
    func signUpWithEmail(email: String, password: String, displayName: String? = nil) {
        state = .signingIn
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.state = .error("Sign up failed: \(error.localizedDescription)")
                    return
                }
                
                guard let user = result?.user else {
                    self?.state = .error("Failed to create user")
                    return
                }
                
                // Update display name if provided
                if let displayName = displayName {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { _ in
                        // Name update is optional, don't fail if it doesn't work
                    }
                }
                
                // State will be updated by auth listener
            }
        }
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            try? GIDSignIn.sharedInstance.signOut()
            // State will be updated by auth listener
        } catch {
            state = .error("Sign out failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete Account
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])
        }
        
        try await user.delete()
        try? GIDSignIn.sharedInstance.signOut()
        // State will be updated by auth listener
    }
    
    // MARK: - Current User Info
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                state = .error("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                state = .error("Unable to fetch identity token")
                return
            }
            
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.state = .error("Firebase authentication failed: \(error.localizedDescription)")
                    } else if authResult?.user != nil {
                        // State will be updated by auth listener
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            if let authError = error as? ASAuthorizationError {
                switch authError.code {
                case .canceled:
                    self.state = .signedOut
                default:
                    self.state = .error("Sign in with Apple failed: \(error.localizedDescription)")
                }
            } else {
                self.state = .error("Sign in with Apple failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Nonce for Sign in with Apple
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // MARK: - SHA256 for Sign in with Apple
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first else {
            fatalError("No window available for Sign in with Apple")
        }
        return window
    }
}