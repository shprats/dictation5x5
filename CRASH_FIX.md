# Crash Fix: Firebase Initialization

## Problem

The app is crashing with `__pthread_kill` error, which typically indicates:
- Firebase not properly initialized
- `GoogleService-Info.plist` missing or not added to target
- Race condition in Firebase initialization

## Fixes Applied

### 1. Firebase Initialization Order
- Added check for `GoogleService-Info.plist` before configuring Firebase
- Added verification that Firebase is configured successfully
- Better error messages if configuration fails

### 2. AuthManager Initialization
- Added check to ensure Firebase is configured before setting up auth listener
- Added graceful error handling
- Delayed listener setup to ensure Firebase is ready

## Verification Steps

### Step 1: Check GoogleService-Info.plist

1. **Verify file exists:**
   - In Xcode, check that `GoogleService-Info.plist` is in the Project Navigator
   - It should be inside the `Dictation5x5` folder

2. **Verify it's added to target:**
   - Select `GoogleService-Info.plist` in Xcode
   - Open File Inspector (right panel)
   - Under "Target Membership", make sure "Dictation5x5" is **checked**

3. **Verify file contents:**
   - Open `GoogleService-Info.plist`
   - Should contain keys like:
     - `PROJECT_ID`
     - `CLIENT_ID`
     - `BUNDLE_ID`
     - `GOOGLE_APP_ID`

### Step 2: Clean Build

1. **Clean build folder:**
   - In Xcode: Product → Clean Build Folder (⌘⇧K)

2. **Delete derived data (if needed):**
   - Xcode → Preferences → Locations
   - Click arrow next to Derived Data path
   - Delete the folder for your project
   - Close and reopen Xcode

3. **Rebuild:**
   - Product → Build (⌘B)
   - Check for any errors

### Step 3: Check Console Output

When you run the app, check the console for:
- `"[AuthManager] Error: Firebase not configured..."` - Means GoogleService-Info.plist issue
- `"Firebase configuration failed..."` - Means Firebase setup issue
- Any other error messages

## Common Issues

### Issue 1: GoogleService-Info.plist Not in Target

**Symptoms:**
- App crashes on launch
- Error about missing Firebase configuration

**Fix:**
1. Select `GoogleService-Info.plist` in Xcode
2. File Inspector → Target Membership
3. Check "Dictation5x5"
4. Clean and rebuild

### Issue 2: Wrong Bundle ID

**Symptoms:**
- Firebase initializes but authentication fails
- "Invalid bundle ID" errors

**Fix:**
1. Check bundle ID in Xcode: Project → Target → General → Bundle Identifier
2. Should match `BUNDLE_ID` in `GoogleService-Info.plist`
3. Should match bundle ID in Firebase Console

### Issue 3: Firebase Not Configured in Firebase Console

**Symptoms:**
- App crashes when trying to authenticate
- "Firebase configuration error"

**Fix:**
1. Go to Firebase Console
2. Verify iOS app is added
3. Download `GoogleService-Info.plist` again
4. Replace the one in your project

## Testing

After applying fixes:

1. **Clean build** (⌘⇧K)
2. **Build** (⌘B) - Should build without errors
3. **Run** (⌘R) - Should launch without crashing
4. **Check console** - Should see Firebase initialization messages
5. **Try login** - Should show login screen (not crash)

## If Still Crashing

1. **Check Xcode console** for specific error messages
2. **Check crash logs:**
   - Window → Devices and Simulators
   - Select your device/simulator
   - View crash logs

3. **Verify Firebase packages:**
   - Project → Package Dependencies
   - Should see: FirebaseAuth, FirebaseCore, GoogleSignIn

4. **Try removing and re-adding GoogleService-Info.plist:**
   - Remove from project (Move to Trash)
   - Download fresh copy from Firebase Console
   - Add to project again
   - Make sure "Copy items if needed" is checked
   - Make sure target is checked

---

**Last Updated:** November 27, 2025

