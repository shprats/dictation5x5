//
//  Colors.swift
//  Dictation5x5
//
//  Brand colors based on logo design
//

import SwiftUI

extension Color {
    // MARK: - Primary Brand Colors
    
    /// Vibrant orange from logo (#FF6B35)
    static let brandOrange = Color(hex: "FF6B35")
    
    /// Medium-dark blue from logo X (#004E89)
    static let brandBlue = Color(hex: "004E89")
    
    /// Light gray background (#F5F5F5)
    static let backgroundGray = Color(hex: "F5F5F5")
    
    // MARK: - Secondary Colors
    
    /// Lighter orange for highlights (#FF8C5A)
    static let orangeLight = Color(hex: "FF8C5A")
    
    /// Darker orange for depth (#E55A2B)
    static let orangeDark = Color(hex: "E55A2B")
    
    /// Lighter blue for accents (#0066B3)
    static let blueLight = Color(hex: "0066B3")
    
    /// Darker blue for depth (#003D6B)
    static let blueDark = Color(hex: "003D6B")
    
    // MARK: - Text Colors
    
    /// Primary text color (#2C2C2C)
    static let textPrimary = Color(hex: "2C2C2C")
    
    /// Secondary text color (#666666)
    static let textSecondary = Color(hex: "666666")
    
    // MARK: - Semantic Colors
    
    /// Success green
    static let successGreen = Color(hex: "4CAF50")
    
    /// Error red
    static let errorRed = Color(hex: "F44336")
    
    /// Warning orange
    static let warningOrange = Color(hex: "FF9800")
}

// MARK: - Hex Color Initializer

extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (e.g., "FF6B35" or "#FF6B35")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

