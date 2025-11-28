# Firebase Setup - Step by Step Guide

## Overview

This guide will walk you through setting up Firebase Authentication for Dictation5x5. Follow these steps in order.

---

## Step 1: Create Firebase Project

1. **Go to Firebase Console:**
   - Visit: https://console.firebase.google.com
   - Sign in with your Google account

2. **Create a new project:**
   - Click "Add project" or "Create a project"
   - Project name: `Dictation5x5` (or your preferred name)
   - Click "Continue"

3. **Configure Google Analytics (optional):**
   - You can enable or disable Google Analytics
   - For this app, it's optional
   - Click "Continue" or "Create project"

4. **Wait for project creation:**
   - This takes about 30 seconds
   - Click "Continue" when ready

---

## Step 2: Add iOS App to Firebase

1. **In Firebase Console:**
   - You should see your project dashboard
   - Click the iOS icon (or "Add app" → iOS)

2. **Register your app:**
   - **iOS bundle ID:** You need to find this first (see Step 2a below)
   - **App nickname:** `Dictation5x5 iOS`
   - **App Store ID:** Leave blank for now
   - Click "Register app"

3. **Find your Bundle ID (Step 2a):**
   - Open Xcode
   - Open `Dictation5x5.xcodeproj`
   - Select the project in Project Navigator
   - Select the "Dictation5x5" target
   - Go to "General" tab
   - Look for "Bundle Identifier" (e.g., `com.yourcompany.dictation5x5`)
   - Copy this value

---

## Step 3: Download GoogleService-Info.plist

1. **After registering your app:**
   - Firebase will show you a download button
   - Click "Download GoogleService-Info.plist"
   - **IMPORTANT:** Save this file - you'll need it in Xcode

2. **Don't close the Firebase console yet** - you'll need it for later steps

---

## Step 4: Add GoogleService-Info.plist to Xcode

1. **Open Xcode:**
   - Open `Dictation5x5.xcodeproj`

2. **Add the file:**
   - Right-click on the `Dictation5x5` folder in Project Navigator
   - Select "Add Files to Dictation5x5..."
   - Navigate to where you saved `GoogleService-Info.plist`
   - Select the file
   - **IMPORTANT:** Make sure "Copy items if needed" is **CHECKED**
   - Make sure "Add to targets: Dictation5x5" is **CHECKED**
   - Click "Add"

3. **Verify:**
   - The file should appear in your Project Navigator
   - It should be inside the `Dictation5x5` folder
   - Try building the project (⌘B) - should build without errors

---

## Step 5: Add Firebase SDK Packages

1. **In Xcode:**
   - File → Add Package Dependencies...
   - Or: Project Settings → Package Dependencies → "+"

2. **Add Firebase iOS SDK:**
   - Enter URL: `https://github.com/firebase/firebase-ios-sdk`
   - Click "Add Package"
   - Wait for package to load

3. **Select products:**
   - ✅ **FirebaseAuth** (required)
   - ✅ **FirebaseCore** (required)
   - Click "Add Package"

4. **Add Google Sign-In SDK:**
   - File → Add Package Dependencies...
   - Enter URL: `https://github.com/google/GoogleSignIn-iOS`
   - Click "Add Package"
   - Select: ✅ **GoogleSignIn**
   - Click "Add Package"

5. **Verify packages:**
   - In Project Navigator, you should see "Package Dependencies"
   - Should include: FirebaseAuth, FirebaseCore, GoogleSignIn

---

## Step 6: Enable Authentication Methods in Firebase

1. **In Firebase Console:**
   - Go to: Authentication (in left sidebar)
   - Click "Get started"

2. **Enable Sign in with Apple:**
   - Click "Sign-in method" tab
   - Click "Sign in with Apple"
   - Toggle "Enable" to ON
   - **Note:** You'll need to configure this in Apple Developer (see Step 7)
   - Click "Save"

3. **Enable Google Sign-In:**
   - Click "Google" in the sign-in methods list
   - Toggle "Enable" to ON
   - Enter a support email (your email)
   - Click "Save"

4. **Enable Email/Password:**
   - Click "Email/Password"
   - Toggle "Email/Password" to ON (first toggle)
   - Leave "Email link (passwordless sign-in)" OFF (optional)
   - Click "Save"

---

## Step 7: Configure Sign in with Apple (Apple Developer)

1. **Go to Apple Developer:**
   - Visit: https://developer.apple.com/account
   - Sign in with your Apple Developer account
   - **Note:** You need a paid Apple Developer account ($99/year)

2. **Create/Configure Service ID:**
   - Go to: Certificates, Identifiers & Profiles
   - Click "Identifiers" in left sidebar
   - Click "+" to create new identifier
   - Select "Services IDs"
   - Click "Continue"
   - Description: `Dictation5x5 Sign in with Apple`
   - Identifier: `com.yourcompany.dictation5x5.signin` (use your bundle ID + `.signin`)
   - Click "Continue" → "Register"

3. **Enable Sign in with Apple:**
   - Click on the Service ID you just created
   - Check "Sign in with Apple"
   - Click "Configure"
   - Primary App ID: Select your app's bundle ID
   - Domains and Subdomains: Your website domain (if you have one, or use a placeholder)
   - Return URLs: `https://YOUR-PROJECT-ID.firebaseapp.com/__/auth/handler`
     - Find YOUR-PROJECT-ID in Firebase Console → Project Settings → General
   - Click "Save" → "Continue" → "Register"

4. **Add Service ID to Firebase:**
   - Go back to Firebase Console
   - Authentication → Sign-in method → Sign in with Apple
   - Enter the Service ID you just created
   - Enter your Apple Developer Team ID (found in Apple Developer account)
   - Click "Save"

---

## Step 8: Enable Sign in with Apple Capability in Xcode

1. **In Xcode:**
   - Select your project in Project Navigator
   - Select the "Dictation5x5" target
   - Go to "Signing & Capabilities" tab

2. **Add capability:**
   - Click "+ Capability"
   - Search for "Sign in with Apple"
   - Double-click to add it

3. **Verify:**
   - "Sign in with Apple" should appear in the capabilities list

---

## Step 9: Configure URL Scheme for Google Sign-In

1. **Find REVERSED_CLIENT_ID:**
   - Open `GoogleService-Info.plist` in Xcode
   - Find the key `REVERSED_CLIENT_ID`
   - Copy its value (starts with `com.googleusercontent.apps.`)

2. **Add URL Scheme:**
   - In Xcode, select your project
   - Select "Dictation5x5" target
   - Go to "Info" tab
   - Expand "URL Types"
   - Click "+" to add new URL Type
   - URL Schemes: Paste the `REVERSED_CLIENT_ID` value
   - Identifier: `GoogleSignIn`

---

## Step 10: Test Authentication

1. **Build and run:**
   - Clean build folder: ⌘⇧K
   - Build: ⌘B
   - Run: ⌘R

2. **Test Sign in with Apple:**
   - Tap "Continue with Apple"
   - Should show Apple sign-in sheet
   - Complete sign-in
   - Should show main app screen

3. **Test Google Sign-In:**
   - Sign out first
   - Tap "Continue with Google"
   - Should show Google sign-in
   - Complete sign-in
   - Should show main app screen

4. **Test Email/Password:**
   - Sign out first
   - Enter email and password
   - Tap "Sign Up" (for new account)
   - Should create account and sign in

---

## Troubleshooting

### "Firebase configuration error"
- Verify `GoogleService-Info.plist` is in the project
- Check it's added to the target
- Clean build folder (⌘⇧K) and rebuild

### "Sign in with Apple failed"
- Verify Sign in with Apple is enabled in Firebase
- Check Service ID is configured in Apple Developer
- Verify capability is added in Xcode
- Check Apple Developer account is active

### "Google Sign-In failed"
- Verify Google Sign-In is enabled in Firebase
- Check URL scheme is added correctly
- Verify GoogleSignIn package is added

### "Unable to find presenting view controller"
- This is a known issue with Google Sign-In
- The app should still work
- May need to adjust implementation for iOS 16+

---

## Verification Checklist

- [ ] Firebase project created
- [ ] iOS app added to Firebase
- [ ] `GoogleService-Info.plist` downloaded and added to Xcode
- [ ] FirebaseAuth package added
- [ ] FirebaseCore package added
- [ ] GoogleSignIn package added
- [ ] Sign in with Apple enabled in Firebase
- [ ] Google Sign-In enabled in Firebase
- [ ] Email/Password enabled in Firebase
- [ ] Service ID created in Apple Developer
- [ ] Sign in with Apple configured in Firebase
- [ ] Sign in with Apple capability added in Xcode
- [ ] URL scheme added for Google Sign-In
- [ ] All authentication methods tested and working

---

## Next Steps

After Firebase is set up:

1. **Test all authentication flows**
2. **Update legal page URLs** in `AppConfig.swift` (after GitHub Pages is set up)
3. **Create app icon** (1024x1024)
4. **Take screenshots** for App Store
5. **Set up App Store Connect**

---

**Time Estimate:** 30-60 minutes  
**Last Updated:** November 2025

