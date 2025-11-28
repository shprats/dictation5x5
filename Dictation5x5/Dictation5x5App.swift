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
    @StateObject private var authManager = AuthManager()
    
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
