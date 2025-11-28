# How to Add URL Scheme for Google Sign-In

## The Problem

The app crashes with this error:
```
'Your app is missing support for the following URL schemes: com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv'
```

## Solution: Add URL Scheme in Xcode

Since your project uses auto-generated Info.plist (`GENERATE_INFOPLIST_FILE = YES`), you need to add the URL scheme through Xcode's UI.

### Step-by-Step Instructions

1. **Open Xcode:**
   - Open `Dictation5x5.xcodeproj`

2. **Select the Project:**
   - Click on the project name "Dictation5x5" in the Project Navigator (top item)

3. **Select the Target:**
   - Under "TARGETS", click "Dictation5x5"

4. **Go to Info Tab:**
   - Click the "Info" tab at the top

5. **Add URL Types:**
   - Scroll down to find "URL Types" section
   - If it doesn't exist, click the "+" button to add it
   - Expand "URL Types" if it's collapsed

6. **Add URL Type:**
   - Click the "+" button under "URL Types"
   - This creates a new URL Type item

7. **Configure the URL Scheme:**
   - Under the new URL Type, find "URL Schemes"
   - Click the "+" button
   - Enter: `com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv`
   - **Identifier:** Enter `GoogleSignIn` (or any identifier you want)

8. **Verify:**
   - The URL scheme should appear in the list
   - Should look like:
     ```
     URL Types
       Item 0
         URL Schemes
           Item 0: com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv
         Identifier: GoogleSignIn
     ```

9. **Build and Run:**
   - Clean build folder: ⌘⇧K
   - Build: ⌘B
   - Run: ⌘R

## Alternative: If Info Tab Doesn't Show URL Types

If you don't see "URL Types" in the Info tab:

1. **Go to Build Settings:**
   - Click "Build Settings" tab
   - Search for "Info.plist"

2. **Or create Info.plist manually:**
   - File → New → File
   - iOS → Property List
   - Name it "Info.plist"
   - Add it to the target
   - Add URL Types manually

## Quick Reference

**URL Scheme to add:**
```
com.googleusercontent.apps.471795025216-ck0n8rsf433df4597cv83c15n44m72gv
```

**Where to find this value:**
- In `GoogleService-Info.plist`
- Look for key: `REVERSED_CLIENT_ID`
- That's the value you need

---

**Last Updated:** November 27, 2025

