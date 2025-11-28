//
//  Dictation5x5App.swift
//  Dictation5x5
//
//  Created by pratik on 9/14/25.
//

import SwiftUI
import FirebaseCore

@main
struct Dictation5x5App: App {
    // Initialize Firebase before anything else
    init() {
        // Initialize Firebase first, before any other code runs
        // Wrap in do-catch to handle any exceptions
        do {
            // Check if GoogleService-Info.plist exists
            if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
                print("✅ [Dictation5x5App] Found GoogleService-Info.plist at: \(path)")
                
                // Configure Firebase
                FirebaseApp.configure()
                
                // Verify configuration
                if FirebaseApp.app() != nil {
                    print("✅ [Dictation5x5App] Firebase configured successfully")
                } else {
                    print("⚠️ [Dictation5x5App] WARNING: Firebase configuration failed. Please check GoogleService-Info.plist")
                }
            } else {
                print("⚠️ [Dictation5x5App] WARNING: GoogleService-Info.plist not found.")
                print("⚠️ Firebase authentication will not work, but app will continue to run.")
                print("⚠️ Please add GoogleService-Info.plist to your project and ensure it's added to the target.")
            }
        } catch {
            print("❌ [Dictation5x5App] ERROR during Firebase initialization: \(error)")
            print("⚠️ App will continue, but authentication features will not work.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
