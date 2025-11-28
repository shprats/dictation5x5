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
        // Check if GoogleService-Info.plist exists
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") == nil {
            print("⚠️ [Dictation5x5App] WARNING: GoogleService-Info.plist not found. Firebase may not work properly.")
            print("⚠️ Please add GoogleService-Info.plist to your project and ensure it's added to the target.")
        }
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Verify configuration
        if FirebaseApp.app() == nil {
            print("⚠️ [Dictation5x5App] WARNING: Firebase configuration failed. Please check GoogleService-Info.plist")
        } else {
            print("✅ [Dictation5x5App] Firebase configured successfully")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
