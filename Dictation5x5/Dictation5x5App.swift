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
        print("🚀 [Dictation5x5App] Starting app initialization...")
        
        // Check if GoogleService-Info.plist exists
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            print("✅ [Dictation5x5App] Found GoogleService-Info.plist at: \(path)")
            
            // Configure Firebase with error handling
            print("🔧 [Dictation5x5App] Configuring Firebase...")
            FirebaseApp.configure()
            print("✅ [Dictation5x5App] FirebaseApp.configure() completed")
            
            // Verify configuration
            if let app = FirebaseApp.app() {
                print("✅ [Dictation5x5App] Firebase configured successfully. App name: \(app.name)")
            } else {
                print("⚠️ [Dictation5x5App] WARNING: FirebaseApp.app() returned nil")
            }
        } else {
            print("⚠️ [Dictation5x5App] WARNING: GoogleService-Info.plist not found.")
            print("⚠️ App will continue, but authentication will not work.")
        }
        
        print("✅ [Dictation5x5App] App initialization complete")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
