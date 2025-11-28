# Firebase Setup Guide for Dictation5x5

## Overview

This app uses Firebase Authentication for user management. You need to set up a Firebase project and configure it before the authentication features will work.

---

## Step 1: Create Firebase Project

1. **Go to Firebase Console:**
   - Visit https://console.firebase.google.com
   - Sign in with your Google account

2. **Create a new project:**
   - Click "Add project" or "Create a project"
   - Enter project name: `Dictation5x5` (or your preferred name)
   - Accept terms and continue
   - Disable Google Analytics (optional) or enable if you want analytics
   - Click "Create project"

---

## Step 2: Add iOS App to Firebase

1. **In Firebase Console:**
   - Click the iOS icon (or "Add app" → iOS)
   - Enter your iOS bundle ID:
     - Find it in Xcode: Project Settings → General → Bundle Identifier
     - Example: `com.yourcompany.dictation5x5`
   - Enter App nickname: `Dictation5x5 iOS`
   - Enter App Store ID (optional, leave blank for now)
   - Click "Register app"

2. **Download GoogleService-Info.plist:**
   - Click "Download GoogleService-Info.plist"
   - **IMPORTANT:** Save this file - you'll need it in Xcode

---

## Step 3: Add GoogleService-Info.plist to Xcode

1. **Open your Xcode project:**
   ```bash
   open Dictation5x5.xcodeproj
   ```

2. **Add the file:**
   - Drag `GoogleService-Info.plist` into the `Dictation5x5` folder in Xcode
   - Make sure "Copy items if needed" is **checked**
   - Make sure "Add to targets: Dictation5x5" is **checked**
   - Click "Finish"

3. **Verify:**
   - The file should appear in your Project Navigator
   - It should be included in the app target

---

## Step 4: Add Firebase SDK via Swift Package Manager

1. **In Xcode:**
   - File → Add Package Dependencies...
   - Enter URL: `https://github.com/firebase/firebase-ios-sdk`
   - Click "Add Package"
   - Select these products:
     - ✅ **FirebaseAuth**
     - ✅ **FirebaseCore**
   - Click "Add Package"

2. **For Google Sign-In:**
   - Add another package:
   - URL: `https://github.com/google/GoogleSignIn-iOS`
   - Select: **GoogleSignIn**

---

## Step 5: Enable Authentication Methods in Firebase

1. **In Firebase Console:**
   - Go to: Authentication → Get started
   - Click "Sign-in method" tab

2. **Enable Sign in with Apple:**
   - Click "Sign in with Apple"
   - Enable it
   - **IMPORTANT:** You also need to configure this in Apple Developer:
     - Go to https://developer.apple.com
     - Certificates, Identifiers & Profiles
     - Identifiers → Services IDs
     - Create/Edit your service ID
     - Enable "Sign in with Apple"
     - Add your domain and return URLs
     - Copy the Service ID and add it to Firebase

3. **Enable Google Sign-In:**
   - Click "Google"
   - Enable it
   - Enter support email
   - Save

4. **Enable Email/Password:**
   - Click "Email/Password"
   - Enable "Email/Password" (first toggle)
   - Enable "Email link (passwordless sign-in)" if desired (optional)
   - Save

---

## Step 6: Configure Sign in with Apple in Apple Developer

1. **Go to Apple Developer:**
   - https://developer.apple.com/account
   - Sign in with your Apple Developer account

2. **Create/Configure Service ID:**
   - Certificates, Identifiers & Profiles
   - Identifiers → Services IDs
   - Click "+" to create new or edit existing
   - Description: "Dictation5x5 Sign in with Apple"
   - Identifier: `com.yourcompany.dictation5x5.signin` (or similar)
   - Enable "Sign in with Apple"
   - Configure:
     - Primary App ID: Your app's bundle ID
     - Domains and Subdomains: Your website domain (if you have one)
     - Return URLs: `https://your-project-id.firebaseapp.com/__/auth/handler`
   - Save

3. **Add Service ID to Firebase:**
   - In Firebase Console → Authentication → Sign-in method → Sign in with Apple
   - Enter the Service ID you just created
   - Save

---

## Step 7: Enable Sign in with Apple Capability in Xcode

1. **In Xcode:**
   - Select your project in Project Navigator
   - Select the "Dictation5x5" target
   - Go to "Signing & Capabilities" tab
   - Click "+ Capability"
   - Add "Sign in with Apple"

---

## Step 8: Update Info.plist (if needed)

The app should automatically read from `GoogleService-Info.plist`, but verify:

1. **Check Info.plist:**
   - Make sure `GoogleService-Info.plist` is in the project
   - Xcode should automatically use it

2. **Add URL Scheme (for Google Sign-In):**
   - In Xcode → Target → Info → URL Types
   - Click "+"
   - Enter URL Scheme: `com.googleusercontent.apps.YOUR-REVERSED-CLIENT-ID`
   - Find `REVERSED_CLIENT_ID` in `GoogleService-Info.plist`
   - Use that value (it starts with `com.googleusercontent.apps.`)

---

## Step 9: Test Authentication

1. **Build and run the app:**
   - ⌘R in Xcode

2. **Test Sign in with Apple:**
   - Tap "Continue with Apple"
   - Should show Apple sign-in sheet
   - Complete sign-in

3. **Test Google Sign-In:**
   - Tap "Continue with Google"
   - Should show Google sign-in
   - Complete sign-in

4. **Test Email/Password:**
   - Enter email and password
   - Tap "Sign Up" or "Sign In"
   - Should authenticate

---

## Troubleshooting

### "Firebase configuration error"
- Make sure `GoogleService-Info.plist` is in the project
- Check that it's added to the target
- Clean build folder (⌘⇧K) and rebuild

### "Sign in with Apple failed"
- Verify Sign in with Apple is enabled in Firebase
- Check Service ID is configured in Apple Developer
- Verify capability is added in Xcode

### "Google Sign-In failed"
- Check URL scheme is added to Info.plist
- Verify Google Sign-In is enabled in Firebase
- Make sure GoogleSignIn package is added

### "Unable to find presenting view controller"
- This is a known issue with Google Sign-In
- The app should still work, but you may need to adjust the implementation

---

## Next Steps

After Firebase is set up:

1. **Update Privacy Policy URLs:**
   - Edit `UserProfileView.swift`
   - Replace `https://yourwebsite.com/privacy-policy` with your actual URL
   - Replace `https://yourwebsite.com/terms` with your actual URL
   - Replace `https://yourwebsite.com/support` with your actual URL

2. **Test all authentication flows:**
   - Sign in with Apple
   - Sign in with Google
   - Email/Password sign up
   - Email/Password sign in
   - Sign out
   - Delete account

3. **Deploy to TestFlight:**
   - Test with beta users
   - Gather feedback

---

## Resources

- Firebase Documentation: https://firebase.google.com/docs/ios/setup
- Sign in with Apple: https://developer.apple.com/sign-in-with-apple/
- Google Sign-In: https://developers.google.com/identity/sign-in/ios

---

**Last Updated:** November 2025

