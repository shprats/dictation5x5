//
//  AppConfig.swift
//  Dictation5x5
//
//  Configuration constants for app-wide settings
//

import Foundation

struct AppConfig {
    // MARK: - Legal & Support URLs
    // Update these URLs with your actual hosted pages
    
    static let privacyPolicyURL = "https://yourwebsite.com/privacy-policy"
    static let termsOfServiceURL = "https://yourwebsite.com/terms"
    static let supportURL = "https://yourwebsite.com/support"
    
    // MARK: - URL Helpers
    
    static var privacyPolicyURLValue: URL? {
        URL(string: privacyPolicyURL)
    }
    
    static var termsOfServiceURLValue: URL? {
        URL(string: termsOfServiceURL)
    }
    
    static var supportURLValue: URL? {
        URL(string: supportURL)
    }
    
    // MARK: - Validation
    
    static func validateURLs() -> [String] {
        var errors: [String] = []
        
        if privacyPolicyURL.contains("yourwebsite.com") {
            errors.append("Privacy Policy URL needs to be updated")
        }
        
        if termsOfServiceURL.contains("yourwebsite.com") {
            errors.append("Terms of Service URL needs to be updated")
        }
        
        if supportURL.contains("yourwebsite.com") {
            errors.append("Support URL needs to be updated")
        }
        
        return errors
    }
}

