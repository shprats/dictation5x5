# Dictation5x5 - Todo List

## ✅ Completed Tasks

### Authentication System
- [x] Set up Firebase Authentication project structure
- [x] Implement real Sign in with Apple using ASAuthorizationController
- [x] Implement Google Sign-In with Firebase
- [x] Implement Email/Password registration and login
- [x] Create Login/SignUp view with all authentication options
- [x] Add sign out functionality with user data cleanup
- [x] Add delete account functionality with confirmation
- [x] Add authentication gate to ContentView (show login if not authenticated)
- [x] Add user profile/settings view with sign out and delete account
- [x] Add links to Privacy Policy, Terms, and Support in settings
- [x] Create centralized URL configuration (AppConfig.swift)
- [x] Add sign out button in SettingsView for easier access
- [x] Add legal links in SettingsView

---

## ⚠️ Pending Tasks (Required for App Store)

### Firebase Setup (CRITICAL - App won't work without this)
- [ ] Create Firebase project at https://console.firebase.google.com
- [ ] Add iOS app to Firebase project
- [ ] Download `GoogleService-Info.plist`
- [ ] Add `GoogleService-Info.plist` to Xcode project
- [ ] Add Firebase SDK packages via Swift Package Manager:
  - [ ] FirebaseAuth
  - [ ] FirebaseCore
  - [ ] GoogleSignIn
- [ ] Enable Sign in with Apple in Firebase Console
- [ ] Enable Google Sign-In in Firebase Console
- [ ] Enable Email/Password in Firebase Console
- [ ] Configure Sign in with Apple in Apple Developer account
- [ ] Enable "Sign in with Apple" capability in Xcode project
- [ ] Test all authentication methods

**Time Estimate:** 30-60 minutes  
**Priority:** 🔴 CRITICAL

---

### Legal Pages (REQUIRED for App Store)
- [ ] Write Privacy Policy content
  - [ ] Data collection explanation
  - [ ] Data usage description
  - [ ] Third-party services disclosure
  - [ ] User rights section
  - [ ] Contact information
- [ ] Write Terms of Service content
  - [ ] Acceptance of terms
  - [ ] Service description
  - [ ] User responsibilities
  - [ ] Liability disclaimers
- [ ] Create Support page
  - [ ] Contact email
  - [ ] FAQ section
  - [ ] Troubleshooting guide
- [ ] Host all pages online (GitHub Pages, Firebase Hosting, or own domain)
- [ ] Update URLs in `AppConfig.swift`:
  - [ ] Privacy Policy URL
  - [ ] Terms of Service URL
  - [ ] Support URL
- [ ] Test all links open correctly

**Time Estimate:** 2-4 hours  
**Priority:** 🔴 CRITICAL

---

### App Store Assets (REQUIRED for App Store)
- [ ] Design app icon (1024x1024 pixels, PNG format)
- [ ] Take screenshots for iPhone 6.7" (1290 x 2796 pixels)
- [ ] Take screenshots for iPhone 6.5" (1242 x 2688 pixels)
- [ ] Take screenshots for iPad Pro 12.9" (if supporting iPad)
- [ ] Write app description (4000 characters max)
- [ ] Write app subtitle (30 characters max)
- [ ] Prepare keywords (100 characters max)
- [ ] Set up App Store Connect listing
- [ ] Configure bundle identifier
- [ ] Set up code signing certificates
- [ ] Create distribution provisioning profile

**Time Estimate:** 2-3 hours  
**Priority:** 🟡 HIGH

---

### Testing & Quality Assurance
- [ ] Test Sign in with Apple
- [ ] Test Sign in with Google
- [ ] Test Email/Password sign up
- [ ] Test Email/Password sign in
- [ ] Test Sign out from Settings
- [ ] Test Sign out from User Profile
- [ ] Test Delete account
- [ ] Test Forgot password flow
- [ ] Test Privacy Policy link
- [ ] Test Terms of Service link
- [ ] Test Support link
- [ ] Test on multiple iOS versions
- [ ] Test on physical device (not just simulator)
- [ ] Test network error handling
- [ ] Test offline mode handling
- [ ] Test microphone permission handling
- [ ] Performance testing
- [ ] Memory leak testing
- [ ] Battery usage testing

**Time Estimate:** 2-3 hours  
**Priority:** 🟡 HIGH

---

### Info.plist Configuration
- [ ] Verify `NSMicrophoneUsageDescription` is set correctly
- [ ] Verify bundle identifier is unique and registered
- [ ] Verify version numbers are set correctly
- [ ] Verify display name is set
- [ ] Add URL scheme for Google Sign-In (if not auto-configured)

**Time Estimate:** 10 minutes  
**Priority:** 🟡 HIGH

---

## 🟢 Optional Enhancements (Nice to Have)

### User Experience
- [ ] Add user onboarding/tutorial for first-time users
- [ ] Add help/instructions section
- [ ] Improve error messages
- [ ] Add loading states for all async operations
- [ ] Add empty states for history when no recordings
- [ ] Add search functionality for transcripts
- [ ] Add export transcripts functionality
- [ ] Add share transcripts functionality

### Accessibility
- [ ] Add VoiceOver support
- [ ] Add Dynamic Type support
- [ ] Improve color contrast
- [ ] Add accessibility labels to all buttons

### Features
- [ ] Cloud sync for transcripts across devices
- [ ] Offline mode with local transcription
- [ ] Multiple language support
- [ ] Custom vocabulary/phrases
- [ ] Audio playback speed control
- [ ] Transcript editing
- [ ] Auto-save drafts

---

## 📊 Progress Summary

### Completed: 12/12 Authentication Tasks ✅
### Pending Critical: 3 major areas
1. Firebase Setup (10 tasks)
2. Legal Pages (6 tasks)
3. App Store Assets (10 tasks)

### Overall Progress: ~40% Complete

---

## 🎯 Next Steps (Priority Order)

1. **Set up Firebase** (30-60 min) - App won't work without this
2. **Test authentication** (30 min) - Verify everything works
3. **Create legal pages** (2-4 hours) - Required for App Store
4. **Update URLs** (5 min) - Quick fix after legal pages are ready
5. **Create app icon** (1-2 hours) - Required for App Store
6. **Take screenshots** (1 hour) - Required for App Store
7. **Set up App Store Connect** (1 hour) - Required for submission

---

## 📚 Documentation Available

- `FIREBASE_SETUP.md` - Step-by-step Firebase setup guide
- `URL_CONFIGURATION_GUIDE.md` - How to update legal page URLs
- `APP_STORE_CHECKLIST.md` - Complete App Store requirements
- `AUTHENTICATION_IMPLEMENTATION_PLAN.md` - Implementation details
- `AUTHENTICATION_IMPLEMENTATION_SUMMARY.md` - What's done and what's next
- `MISSING_FOR_APP_STORE.md` - What's still missing
- `SIGN_OUT_AND_LINKS_SUMMARY.md` - Sign out and links implementation

---

**Last Updated:** November 2025  
**Status:** Authentication complete, awaiting Firebase setup and legal pages

