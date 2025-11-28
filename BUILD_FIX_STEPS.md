# Fix: Multiple Commands Produce Info.plist + URL Scheme Not Working

## Current Status

✅ **URL Scheme is correctly configured** in Xcode's Info tab:
- Identifier: `GoogleSignIn`
- URL Scheme: `com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv`

❌ **But you're still getting:**
1. Build error: "Multiple commands produce Info.plist"
2. Runtime crash: "Your app is missing support for the following URL schemes"

## Root Cause

When using `GENERATE_INFOPLIST_FILE = YES`, Xcode auto-generates Info.plist. The URL Types you configure in the Info tab should be included, but sometimes:
- Xcode's build cache gets confused
- The URL scheme doesn't get properly merged into the generated Info.plist
- There might be a stale build artifact

## Solution: Clean Build + Verify

### Step 1: Clean Everything
1. In Xcode, go to **Product → Clean Build Folder** (⌘⇧K)
2. Close Xcode completely
3. Delete DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Dictation5x5-*
   ```
4. Reopen Xcode

### Step 2: Verify URL Scheme in Info Tab
1. Select project → Target "Dictation5x5" → **Info** tab
2. Verify **URL Types** section shows:
   - **Identifier:** `GoogleSignIn`
   - **URL Schemes:** `com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv`
   - **Role:** `Editor`

### Step 3: Build and Check Generated Info.plist
1. Build the project (⌘B)
2. After build succeeds, check the generated Info.plist:
   - Right-click on the app in Products folder → **Show in Finder**
   - Or check: `~/Library/Developer/Xcode/DerivedData/Dictation5x5-*/Build/Products/Debug-iphonesimulator/Dictation5x5.app/Info.plist`
3. Open Info.plist and verify it contains:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLName</key>
           <string>GoogleSignIn</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv</string>
           </array>
       </dict>
   </array>
   ```

### Step 4: If URL Scheme is Missing from Generated Info.plist

If the URL scheme is configured in Info tab but not in the generated Info.plist, you need to add it via Build Settings:

1. Go to **Build Settings** tab
2. Search for: `INFOPLIST_KEY_CFBundleURLTypes`
3. If it doesn't exist, you'll need to add it manually via a script or use a different approach

**Alternative: Use Build Settings Directly**

Instead of using the Info tab, add the URL scheme via Build Settings:

1. Go to **Build Settings** tab
2. Search for: `INFOPLIST`
3. Click the **"+"** button → **Add User-Defined Setting**
4. Name it: `INFOPLIST_KEY_CFBundleURLTypes`
5. Set the value to a plist array (this is complex)

**Better Alternative: Create Info.plist Manually**

If the auto-generation isn't working properly:

1. **File → New → File**
2. **iOS → Property List**
3. Name it: `Info.plist`
4. Save it in the `Dictation5x5` folder
5. Add this content:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>GoogleSignIn</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv</string>
            </array>
        </dict>
    </array>
    <key>NSMicrophoneUsageDescription</key>
    <string>We would be accessing the microphone to listen in when the start button is pressed and to transcribe the notes.</string>
</dict>
</plist>
```

6. In **Build Settings**, set:
   - `GENERATE_INFOPLIST_FILE = NO`
   - `INFOPLIST_FILE = Dictation5x5/Info.plist`

7. Clean and rebuild

---

## Quick Fix: Try This First

1. **Clean Build Folder** (⌘⇧K)
2. **Quit Xcode** completely
3. **Delete DerivedData:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Dictation5x5-*
   ```
4. **Reopen Xcode**
5. **Build** (⌘B)
6. **Run** (⌘R)

If it still doesn't work, use the manual Info.plist approach above.

---

## Verification

After fixing, verify:
1. ✅ Build succeeds without "Multiple commands" error
2. ✅ App launches without crashing
3. ✅ Google Sign-In button works
4. ✅ Check generated Info.plist contains URL scheme

---

**Last Updated:** November 27, 2025

