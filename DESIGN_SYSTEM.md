# Dictation5x5 Design System

## Color Palette

Based on your logo, here's the official color palette:

### Primary Colors
- **Orange Primary:** `#FF6B35` (Vibrant orange from the logo)
- **Blue Primary:** `#004E89` (Medium-dark blue from the X)
- **Background Gray:** `#F5F5F5` (Light gray/off-white background)

### Secondary Colors
- **Orange Light:** `#FF8C5A` (Lighter orange for highlights)
- **Orange Dark:** `#E55A2B` (Darker orange for depth)
- **Blue Light:** `#0066B3` (Lighter blue for accents)
- **Blue Dark:** `#003D6B` (Darker blue for depth)
- **Text Dark:** `#2C2C2C` (Dark gray for text)
- **Text Light:** `#666666` (Medium gray for secondary text)

### Semantic Colors
- **Success:** `#4CAF50` (Green)
- **Error:** `#F44336` (Red)
- **Warning:** `#FF9800` (Orange)
- **Info:** `#004E89` (Blue Primary)

---

## Typography

### Font Family
- **Primary:** SF Pro (System font)
- **Display:** SF Pro Display (for large headings)
- **Monospace:** SF Mono (for code/technical text)

### Font Sizes
- **Large Title:** 34pt (Bold)
- **Title 1:** 28pt (Bold)
- **Title 2:** 22pt (Bold)
- **Title 3:** 20pt (Semibold)
- **Headline:** 17pt (Semibold)
- **Body:** 17pt (Regular)
- **Callout:** 16pt (Regular)
- **Subheadline:** 15pt (Regular)
- **Footnote:** 13pt (Regular)
- **Caption 1:** 12pt (Regular)
- **Caption 2:** 11pt (Regular)

---

## App Icon Specifications

### Design Concept
The app icon should be a simplified, recognizable version of your logo that works at small sizes.

### Icon Design (1024x1024px)

**Base Design:**
- **Background:** Solid orange (`#FF6B35`) or gradient from orange to light orange
- **Foreground:** Two white "5"s stacked vertically
- **Accent:** Blue "X" crossing over the "5"s (slightly transparent or outlined)

**Alternative Design (Simplified):**
- **Background:** White or light gray (`#F5F5F5`)
- **Two orange "5"s** stacked vertically
- **Blue "X"** crossing over them
- **Orange border/arcs** framing the design

**Minimal Design (For small sizes):**
- **Background:** Orange (`#FF6B35`)
- **Single white "5"** in the center
- **Blue diagonal line** crossing it (simplified X)

### Technical Requirements
- **Size:** 1024x1024 pixels
- **Format:** PNG (no transparency for App Store)
- **Color Space:** sRGB
- **No rounded corners** (iOS adds them automatically)
- **No text or UI elements** (just the icon design)
- **Works at small sizes** (test at 20x20, 40x40, 60x60 pixels)

---

## UI Component Styles

### Buttons

**Primary Button (Orange):**
- Background: Orange Primary (`#FF6B35`)
- Text: White
- Corner Radius: 12px
- Padding: 16px vertical, 24px horizontal
- Font: Headline (17pt, Semibold)

**Secondary Button (Blue):**
- Background: Blue Primary (`#004E89`)
- Text: White
- Corner Radius: 12px
- Padding: 16px vertical, 24px horizontal
- Font: Headline (17pt, Semibold)

**Tertiary Button (Outline):**
- Background: Transparent
- Border: 2px solid Orange Primary
- Text: Orange Primary
- Corner Radius: 12px
- Padding: 16px vertical, 24px horizontal

### Cards/Surfaces
- Background: White or light gray (`#F5F5F5`)
- Corner Radius: 16px
- Shadow: Subtle shadow for depth
- Padding: 20px

### Input Fields
- Background: White
- Border: 1px solid light gray (`#E0E0E0`)
- Corner Radius: 8px
- Padding: 12px
- Focus State: Border color changes to Orange Primary

---

## App Theme Implementation

### SwiftUI Color Extensions

Create a `Colors.swift` file with your brand colors:

```swift
import SwiftUI

extension Color {
    // Primary Colors
    static let brandOrange = Color(hex: "FF6B35")
    static let brandBlue = Color(hex: "004E89")
    static let backgroundGray = Color(hex: "F5F5F5")
    
    // Secondary Colors
    static let orangeLight = Color(hex: "FF8C5A")
    static let orangeDark = Color(hex: "E55A2B")
    static let blueLight = Color(hex: "0066B3")
    static let blueDark = Color(hex: "003D6B")
    
    // Text Colors
    static let textPrimary = Color(hex: "2C2C2C")
    static let textSecondary = Color(hex: "666666")
}

extension Color {
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
```

---

## Icon Assets Needed

### App Icon Sizes (App Store)
- **1024x1024px** - Main app icon (required)

### App Icon Sizes (iOS)
- **20x20pt** (@2x: 40x40px, @3x: 60x60px) - Notification
- **29x29pt** (@2x: 58x58px, @3x: 87x87px) - Settings
- **40x40pt** (@2x: 80x80px, @3x: 120x120px) - Spotlight
- **60x60pt** (@2x: 120x120px, @3x: 180x180px) - App Icon
- **76x76pt** (@2x: 152x152px) - iPad App Icon
- **83.5x83.5pt** (@2x: 167x167px) - iPad Pro App Icon
- **1024x1024px** - App Store

### System Icons (SF Symbols)
Use SF Symbols where possible, but customize colors:
- Microphone: `mic.fill` (Orange)
- Play: `play.circle.fill` (Orange)
- Stop: `stop.circle.fill` (Blue)
- Settings: `gear` (Gray)
- History: `clock.arrow.circlepath` (Blue)

---

## Design Principles

1. **Bold & Clear:** Use the vibrant orange and blue colors prominently
2. **Simple & Clean:** Keep the design minimal, like your logo
3. **Accessible:** Ensure good contrast ratios (WCAG AA minimum)
4. **Consistent:** Use the same color palette throughout
5. **Recognizable:** The orange/blue combination should be distinctive

---

## Implementation Checklist

- [ ] Create 1024x1024 app icon
- [ ] Create all required icon sizes
- [ ] Implement color extensions in SwiftUI
- [ ] Update button styles to use brand colors
- [ ] Update accent colors in Assets.xcassets
- [ ] Create custom SF Symbols where needed
- [ ] Test icon at all sizes
- [ ] Ensure accessibility compliance

---

**Last Updated:** November 2025

