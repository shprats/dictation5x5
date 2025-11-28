# Fix: Multiple Commands Produce Info.plist Error

## Problem

You're getting this error:
```
Multiple commands produce '/Users/.../Info.plist'
```

This happens because:
- Your project uses **auto-generated Info.plist** (`GENERATE_INFOPLIST_FILE = YES`)
- A manual `Info.plist` file was created
- Xcode is trying to use both, causing a conflict

## Solution

I've removed the manual `Info.plist` file. Now you need to add the URL scheme through Xcode's UI.

---

## Step-by-Step: Add URL Scheme in Xcode

### Step 1: Open Project Settings
1. In Xcode, click on **"Dictation5x5"** (the project, top item in Project Navigator)
2. Under **"TARGETS"**, select **"Dictation5x5"**

### Step 2: Go to Info Tab
1. Click the **"Info"** tab at the top

### Step 3: Add URL Types
1. Scroll down to find **"URL Types"** section
   - If you don't see it, click the **"+"** button at the bottom to add it
2. Expand **"URL Types"** (click the disclosure triangle if collapsed)

### Step 4: Add URL Type
1. Click the **"+"** button under "URL Types"
2. This creates a new "Item 0" entry

### Step 5: Configure URL Scheme
1. Under the new URL Type, find **"URL Schemes"**
2. Click the **"+"** button next to "URL Schemes"
3. Enter this exact value:
   ```
   com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv
   ```

### Step 6: Set Identifier
1. Find **"Identifier"** field (usually above URL Schemes)
2. Enter: `GoogleSignIn`

### Step 7: Verify
Your URL Types section should look like this:
```
URL Types
  └─ Item 0
      ├─ Identifier: GoogleSignIn
      └─ URL Schemes
          └─ Item 0: com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv
```

### Step 8: Build and Run
1. **Clean:** Product → Clean Build Folder (⌘⇧K)
2. **Build:** Product → Build (⌘B)
3. **Run:** Product → Run (⌘R)

---

## Alternative: If Info Tab Doesn't Show URL Types

If you can't find "URL Types" in the Info tab:

### Option 1: Use Build Settings
1. Go to **"Build Settings"** tab
2. Search for: `INFOPLIST`
3. Look for `INFOPLIST_KEY_CFBundleURLTypes`
4. Add the URL scheme there (complex, not recommended)

### Option 2: Create Info.plist Manually
1. File → New → File
2. iOS → Property List
3. Name it "Info.plist"
4. Add URL Types manually
5. In Build Settings, set `GENERATE_INFOPLIST_FILE = NO`
6. Set `INFOPLIST_FILE = Dictation5x5/Info.plist`

**But Option 1 (using Info tab) is much easier!**

---

## Quick Reference

**URL Scheme to add:**
```
com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv
```

**Where to find this:**
- In `GoogleService-Info.plist`
- Key: `REVERSED_CLIENT_ID`
- Value: `com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv`

---

## After Adding URL Scheme

Once you've added the URL scheme:
1. Clean build folder (⌘⇧K)
2. Build (⌘B) - should build without errors
3. Run (⌘R) - app should launch
4. Try Google Sign-In - should work without crashing

---

**Last Updated:** November 27, 2025

