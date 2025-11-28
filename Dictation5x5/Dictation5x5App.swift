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
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            fatalError("GoogleService-Info.plist not found. Please add it to your project.")
        }
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Verify configuration
        guard FirebaseApp.app() != nil else {
            fatalError("Firebase configuration failed. Please check GoogleService-Info.plist")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
