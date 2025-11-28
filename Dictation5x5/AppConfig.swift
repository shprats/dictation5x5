//
//  AppConfig.swift
//  Dictation5x5
//
//  Configuration constants for app-wide settings
//

import Foundation

struct AppConfig {
    // MARK: - Legal & Support URLs
    // GitHub Pages URLs for legal documents
    
    static let privacyPolicyURL = "https://shprats.github.io/dictation5x5/privacy-policy.html"
    static let termsOfServiceURL = "https://shprats.github.io/dictation5x5/terms.html"
    static let supportURL = "https://shprats.github.io/dictation5x5/support.html"
    
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

