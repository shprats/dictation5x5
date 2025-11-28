# Firebase Setup - Pending Tasks

## ✅ Completed (Steps 1-7)

Based on your code review, you have completed:

- [x] **Step 1:** Firebase project created
- [x] **Step 2:** iOS app added to Firebase
- [x] **Step 3:** `GoogleService-Info.plist` downloaded and added to Xcode
- [x] **Step 4:** Firebase SDK packages added (FirebaseAuth, FirebaseCore, GoogleSignIn)
- [x] **Step 5:** Authentication methods enabled in Firebase Console
- [x] **Step 6:** Firebase initialized in code (`Dictation5x5App.swift`)
- [x] **Step 7:** Sign in with Apple configuration in Apple Developer (PENDING - see details below)

---

## ⚠️ Pending Tasks

### Step 7: Complete Sign in with Apple Configuration

**Your Apple Developer Program Enrollment ID:** `Q9BR66F399`

You need to complete these sub-steps:

#### 7a. Create Service ID in Apple Developer

1. **Go to Apple Developer:**
   - Visit: https://developer.apple.com/account
   - Sign in with your Apple Developer account

2. **Create Service ID:**
   - Go to: Certificates, Identifiers & Profiles
   - Click "Identifiers" in left sidebar
   - Click "+" to create new identifier
   - Select "Services IDs"
   - Click "Continue"
   - **Description:** `Dictation5x5 Sign in with Apple`
   - **Identifier:** `com.yourcompany.dictation5x5.signin`
     - ⚠️ **IMPORTANT:** Replace `com.yourcompany.dictation5x5` with your actual bundle ID
     - To find your bundle ID: Xcode → Project → Target → General → Bundle Identifier
   - Click "Continue" → "Register"

#### 7b. Configure Service ID

1. **Click on the Service ID you just created**

2. **Enable Sign in with Apple:**
   - Check the box "Sign in with Apple"
   - Click "Configure"

3. **Configure settings:**
   - **Primary App ID:** Select your app's bundle ID (the main app, not the service ID)
   - **Domains and Subdomains:** 
     - If you have a website: Enter your domain
     - If not: You can use a placeholder like `dictation5x5.app` (this won't be used but is required)
   - **Return URLs:** 
     - You need your Firebase project's auth handler URL
     - Format: `https://YOUR-PROJECT-ID.firebaseapp.com/__/auth/handler`
     - **To find YOUR-PROJECT-ID:**
       1. Go to Firebase Console: https://console.firebase.google.com
       2. Select your project
       3. Click the gear icon → Project Settings
       4. Under "General" tab, find "Project ID"
       5. Use that Project ID in the return URL
   - Click "Save" → "Continue" → "Register"

#### 7c. Add Service ID to Firebase

1. **Go to Firebase Console:**
   - https://console.firebase.google.com
   - Select your project

2. **Configure Sign in with Apple:**
   - Go to: Authentication → Sign-in method
   - Click "Sign in with Apple"
   - **Service ID:** Enter the Service ID you created (e.g., `com.yourcompany.dictation5x5.signin`)
   - **Apple Developer Team ID:** `Q9BR66F399` (your enrollment ID)
   - Click "Save"

---

### Step 8: Enable Sign in with Apple Capability in Xcode

1. **Open Xcode:**
   - Open `Dictation5x5.xcodeproj`

2. **Add capability:**
   - Select your project in Project Navigator
   - Select the "Dictation5x5" target
   - Go to "Signing & Capabilities" tab
   - Click "+ Capability"
   - Search for "Sign in with Apple"
   - Double-click to add it

3. **Verify:**
   - "Sign in with Apple" should appear in the capabilities list

---

### Step 9: Configure URL Scheme for Google Sign-In

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
   - **URL Schemes:** Paste the `REVERSED_CLIENT_ID` value
   - **Identifier:** `GoogleSignIn`

3. **Verify:**
   - The URL scheme should appear in the list

---

### Step 10: Test Authentication

1. **Build and run:**
   - Clean build folder: ⌘⇧K
   - Build: ⌘B
   - Run: ⌘R

2. **Test each authentication method:**
   - Sign in with Apple
   - Sign in with Google
   - Email/Password sign up
   - Email/Password sign in
   - Sign out
   - Delete account

---

## 🔍 Quick Verification Checklist

Before testing, verify:

- [ ] `GoogleService-Info.plist` is in Xcode project and added to target
- [ ] Firebase packages are added (FirebaseAuth, FirebaseCore, GoogleSignIn)
- [ ] Firebase is initialized in `Dictation5x5App.swift` ✅ (Already done)
- [ ] Sign in with Apple capability is added in Xcode
- [ ] URL scheme for Google Sign-In is configured
- [ ] Service ID is created in Apple Developer
- [ ] Service ID is configured in Firebase Console
- [ ] All authentication methods are enabled in Firebase Console

---

## 📝 Important Notes

1. **Bundle ID:** Make sure you use your actual bundle ID (not `com.yourcompany.dictation5x5`)
   - Find it in: Xcode → Project → Target → General → Bundle Identifier

2. **Firebase Project ID:** You need this for the Return URL in Apple Developer
   - Find it in: Firebase Console → Project Settings → General → Project ID

3. **Team ID:** Your Apple Developer Team ID is `Q9BR66F399`

4. **Service ID Format:** Should be your bundle ID + `.signin`
   - Example: If bundle ID is `com.shprats.dictation5x5`, Service ID should be `com.shprats.dictation5x5.signin`

---

## 🚨 Common Issues

### "Sign in with Apple failed"
- Verify Service ID is created and configured correctly
- Check that Service ID is added to Firebase Console
- Verify Team ID is correct (`Q9BR66F399`)
- Ensure capability is added in Xcode

### "Google Sign-In failed"
- Check URL scheme is added correctly
- Verify `REVERSED_CLIENT_ID` from `GoogleService-Info.plist` is used
- Ensure Google Sign-In is enabled in Firebase Console

### "Firebase configuration error"
- Verify `GoogleService-Info.plist` is in project and added to target
- Check that Firebase packages are properly linked

---

**Last Updated:** November 27, 2025  
**Status:** Steps 1-6 complete, Steps 7-10 pending

