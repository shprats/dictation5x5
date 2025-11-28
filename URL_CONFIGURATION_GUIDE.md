# URL Configuration Guide

## Overview

The app now has a centralized configuration system for legal and support URLs. All URLs are managed in `AppConfig.swift` for easy updates.

---

## How to Update URLs

### Step 1: Open AppConfig.swift

In Xcode, navigate to:
```
Dictation5x5/AppConfig.swift
```

### Step 2: Update the URLs

Find these constants at the top of the file:

```swift
static let privacyPolicyURL = "https://yourwebsite.com/privacy-policy"
static let termsOfServiceURL = "https://yourwebsite.com/terms"
static let supportURL = "https://yourwebsite.com/support"
```

Replace with your actual URLs:

```swift
static let privacyPolicyURL = "https://yourdomain.com/privacy-policy"
static let termsOfServiceURL = "https://yourdomain.com/terms"
static let supportURL = "https://yourdomain.com/support"
```

### Step 3: Build and Test

1. Build the project (⌘B)
2. Run the app
3. Go to Settings → Legal & Support section
4. Tap each link to verify they open correctly

---

## Where URLs Are Used

The URLs configured in `AppConfig.swift` are automatically used in:

1. **SettingsView** - Legal & Support section
2. **UserProfileView** - Legal & Support section

Both views will:
- Show clickable links if URLs are valid
- Show "Not configured" if URLs contain placeholder text
- Handle invalid URLs gracefully

---

## URL Validation

The `AppConfig` includes a validation function that checks if URLs are still using placeholder values:

```swift
let errors = AppConfig.validateURLs()
// Returns array of strings indicating which URLs need updating
```

This can be used during development to ensure all URLs are configured before release.

---

## Sign Out Functionality

Sign out is now available in **two locations**:

1. **SettingsView** - Direct sign out button in "Account Actions" section
2. **UserProfileView** - Sign out button in "Actions" section

Both locations:
- Show a confirmation dialog before signing out
- Automatically dismiss the view after signing out
- Return user to login screen

---

## Features Implemented

### ✅ Sign Out
- Available in Settings and User Profile
- Confirmation dialog before signing out
- Automatic navigation to login screen

### ✅ Legal Links
- Privacy Policy link
- Terms of Service link
- Support link
- All links open in Safari
- Graceful handling of invalid/missing URLs

### ✅ Centralized Configuration
- All URLs in one file (`AppConfig.swift`)
- Easy to update
- Type-safe URL handling
- Validation helper function

---

## Testing Checklist

- [ ] Update URLs in `AppConfig.swift`
- [ ] Test Privacy Policy link opens correctly
- [ ] Test Terms of Service link opens correctly
- [ ] Test Support link opens correctly
- [ ] Test Sign Out from Settings
- [ ] Test Sign Out from User Profile
- [ ] Verify user is returned to login screen after sign out
- [ ] Test with invalid URLs (should show "Not configured")

---

## Example URLs

If you're using GitHub Pages:

```swift
static let privacyPolicyURL = "https://yourusername.github.io/dictation5x5/privacy-policy"
static let termsOfServiceURL = "https://yourusername.github.io/dictation5x5/terms"
static let supportURL = "https://yourusername.github.io/dictation5x5/support"
```

If you're using Firebase Hosting:

```swift
static let privacyPolicyURL = "https://your-project-id.web.app/privacy-policy"
static let termsOfServiceURL = "https://your-project-id.web.app/terms"
static let supportURL = "https://your-project-id.web.app/support"
```

If you have your own domain:

```swift
static let privacyPolicyURL = "https://dictation5x5.com/privacy-policy"
static let termsOfServiceURL = "https://dictation5x5.com/terms"
static let supportURL = "https://dictation5x5.com/support"
```

---

## Troubleshooting

### Links don't open
- Check that URLs are valid (start with `https://`)
- Verify URLs are accessible in a browser
- Check that URLs don't contain placeholder text

### "Not configured" appears
- This means the URL still contains "yourwebsite.com"
- Update the URL in `AppConfig.swift`
- Rebuild the app

### Sign out doesn't work
- Check Firebase is properly configured
- Verify `AuthManager` is initialized correctly
- Check console for error messages

---

**Last Updated:** November 2025

