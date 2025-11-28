# Firebase Setup - Exact Steps with Your Values

## ✅ What's Already Done

- [x] Firebase project created (`dictation5x5`)
- [x] iOS app added to Firebase
- [x] `GoogleService-Info.plist` downloaded and added to Xcode
- [x] Firebase packages added (FirebaseAuth, FirebaseCore, GoogleSignIn)
- [x] Firebase initialized in code
- [x] Authentication methods enabled in Firebase Console

---

## ⚠️ What's Pending (Steps 7-10)

### Your Configuration Values

- **Bundle ID:** `iDocs.Dictation5x5`
- **Service ID (to create):** `iDocs.Dictation5x5.signin`
- **Apple Developer Team ID:** `Q9BR66F399`
- **Firebase Project ID:** `dictation5x5`
- **Firebase Return URL:** `https://dictation5x5.firebaseapp.com/__/auth/handler`
- **REVERSED_CLIENT_ID:** `com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv`

---

## Step 7: Complete Sign in with Apple Configuration

### 7a. Create Service ID in Apple Developer

1. **Go to Apple Developer:**
   - Visit: https://developer.apple.com/account
   - Sign in with your Apple Developer account

2. **Create Service ID:**
   - Go to: Certificates, Identifiers & Profiles
   - Click "Identifiers" in left sidebar
   - Click "+" (top left) to create new identifier
   - Select "Services IDs"
   - Click "Continue"

3. **Enter details:**
   - **Description:** `Dictation5x5 Sign in with Apple`
   - **Identifier:** `iDocs.Dictation5x5.signin` ⬅️ **Use this exact value**
   - Click "Continue"
   - Click "Register"

### 7b. Configure Service ID

1. **Click on the Service ID you just created** (`iDocs.Dictation5x5.signin`)

2. **Enable Sign in with Apple:**
   - Check the box "Sign in with Apple"
   - Click "Configure" button

3. **Configure settings:**
   - **Primary App ID:** Select `iDocs.Dictation5x5` (your main app bundle ID)
   - **Domains and Subdomains:** 
     - Enter: `dictation5x5.firebaseapp.com`
     - (This is your Firebase hosting domain)
   - **Return URLs:** 
     - Click "+" to add
     - Enter: `https://dictation5x5.firebaseapp.com/__/auth/handler` ⬅️ **Use this exact URL**
     - Click "Save"
   - Click "Continue"
   - Click "Save" (top right)

### 7c. Add Service ID to Firebase

1. **Go to Firebase Console:**
   - Visit: https://console.firebase.google.com
   - Select your project: `dictation5x5`

2. **Configure Sign in with Apple:**
   - Go to: Authentication → Sign-in method
   - Click "Sign in with Apple" (should show as enabled)
   - **Service ID:** Enter `iDocs.Dictation5x5.signin` ⬅️ **Use this exact value**
   - **Apple Developer Team ID:** Enter `Q9BR66F399` ⬅️ **Your Team ID**
   - Click "Save"

---

## Step 8: Enable Sign in with Apple Capability in Xcode

1. **Open Xcode:**
   ```bash
   open Dictation5x5.xcodeproj
   ```

2. **Add capability:**
   - Select your project in Project Navigator (top item)
   - Select the "Dictation5x5" target (under TARGETS)
   - Go to "Signing & Capabilities" tab
   - Click "+ Capability" (top left)
   - Search for "Sign in with Apple"
   - Double-click "Sign in with Apple" to add it

3. **Verify:**
   - "Sign in with Apple" should appear in the capabilities list
   - Should show your Team ID: `Q9BR66F399`

---

## Step 9: Configure URL Scheme for Google Sign-In

1. **In Xcode:**
   - Select your project in Project Navigator
   - Select "Dictation5x5" target
   - Go to "Info" tab

2. **Add URL Type:**
   - Scroll down to "URL Types"
   - Click "+" to add new URL Type
   - **URL Schemes:** Enter `com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv` ⬅️ **Use this exact value**
   - **Identifier:** Enter `GoogleSignIn`

3. **Verify:**
   - The URL scheme should appear in the list
   - Should match the REVERSED_CLIENT_ID from `GoogleService-Info.plist`

---

## Step 10: Test Authentication

1. **Build and run:**
   - Clean build folder: ⌘⇧K (Shift + Command + K)
   - Build: ⌘B (Command + B)
   - Run: ⌘R (Command + R)

2. **Test Sign in with Apple:**
   - Tap "Continue with Apple"
   - Should show Apple sign-in sheet
   - Complete sign-in
   - Should show main app screen

3. **Test Google Sign-In:**
   - Sign out first (Settings → Account Actions → Sign Out)
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

## ✅ Final Verification Checklist

Before testing, verify all of these:

- [ ] Service ID created: `iDocs.Dictation5x5.signin`
- [ ] Service ID configured with Return URL: `https://dictation5x5.firebaseapp.com/__/auth/handler`
- [ ] Service ID added to Firebase Console with Team ID: `Q9BR66F399`
- [ ] Sign in with Apple capability added in Xcode
- [ ] URL scheme added: `com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv`
- [ ] All authentication methods enabled in Firebase Console:
  - [ ] Sign in with Apple
  - [ ] Google Sign-In
  - [ ] Email/Password

---

## 🚨 Troubleshooting

### "Sign in with Apple failed"
- Verify Service ID `iDocs.Dictation5x5.signin` is created in Apple Developer
- Check Return URL is exactly: `https://dictation5x5.firebaseapp.com/__/auth/handler`
- Verify Service ID is added to Firebase with Team ID `Q9BR66F399`
- Ensure capability is added in Xcode

### "Google Sign-In failed"
- Check URL scheme matches exactly: `com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv`
- Verify Google Sign-In is enabled in Firebase Console

### "Firebase configuration error"
- Verify `GoogleService-Info.plist` is in Xcode project
- Check it's added to the target (should be in Resources)

---

## 📝 Summary

**What you need to do:**

1. ✅ Create Service ID: `iDocs.Dictation5x5.signin` in Apple Developer
2. ✅ Configure it with Return URL: `https://dictation5x5.firebaseapp.com/__/auth/handler`
3. ✅ Add Service ID to Firebase with Team ID: `Q9BR66F399`
4. ✅ Add Sign in with Apple capability in Xcode
5. ✅ Add URL scheme for Google Sign-In
6. ✅ Test all authentication methods

**Estimated time:** 15-20 minutes

---

**Last Updated:** November 27, 2025

