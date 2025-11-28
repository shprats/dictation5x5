# App Store Submission Checklist for Dictation5x5

## Authentication & User Management (REQUIRED)

### ✅ Current Status: Partially Implemented (Stubs Only)

- [ ] **Implement real authentication** (currently stubs in AuthManager.swift)
- [ ] **Sign in with Apple** - Full implementation with ASAuthorizationController
- [ ] **Sign in with Google** - Firebase Auth or Google Sign-In SDK
- [ ] **Email/Password authentication** - Registration and login
- [ ] **Sign out functionality** - Clear user data and return to login
- [ ] **Delete account functionality** - Remove user data and account
- [ ] **User session persistence** - Remember login state across app launches
- [ ] **Password reset** - Forgot password flow
- [ ] **Email verification** - Verify email addresses for new accounts

### Required UI Components

- [ ] **Login/Sign Up Screen** - First screen users see if not authenticated
- [ ] **Authentication flow** - Seamless onboarding
- [ ] **User profile/settings** - Show logged-in user info
- [ ] **Sign out button** - In settings or profile
- [ ] **Delete account button** - With confirmation dialog

---

## Legal & Policy Requirements (REQUIRED)

### Privacy Policy

- [ ] **Privacy Policy URL** - Must be accessible, hosted online
- [ ] **Privacy Policy content** covering:
  - [ ] What data is collected (audio, transcripts, user info)
  - [ ] How data is used (transcription, storage)
  - [ ] Data storage location (local device, cloud)
  - [ ] Third-party services (Google Cloud Speech-to-Text)
  - [ ] User rights (access, delete, export)
  - [ ] Data retention policies
  - [ ] Contact information for privacy inquiries

### Terms of Service

- [ ] **Terms of Service URL** - Accessible online
- [ ] **Terms content** covering:
  - [ ] App usage terms
  - [ ] User responsibilities
  - [ ] Service limitations
  - [ ] Intellectual property
  - [ ] Liability disclaimers

### Support

- [ ] **Support page/URL** - Accessible from app
- [ ] **Support contact** - Email or support system
- [ ] **FAQ section** - Common questions answered
- [ ] **In-app support** - Help/support section

---

## App Store Requirements (CRITICAL)

### App Information

- [ ] **App Name** - "Dictation5x5" (or your chosen name)
- [ ] **Subtitle** - Brief description (30 chars)
- [ ] **Description** - Detailed app description (4000 chars max)
- [ ] **Keywords** - Search keywords (100 chars)
- [ ] **Category** - Primary: Medical, Secondary: Productivity
- [ ] **Age Rating** - Complete questionnaire (likely 4+)
- [ ] **App Icon** - 1024x1024px PNG (no transparency, no rounded corners)
- [ ] **Screenshots** - Required for all device sizes:
  - [ ] iPhone 6.7" (iPhone 14 Pro Max) - 3-10 screenshots
  - [ ] iPhone 6.5" (iPhone 11 Pro Max) - 3-10 screenshots
  - [ ] iPad Pro 12.9" (if supporting iPad) - 3-10 screenshots

### App Store Connect Setup

- [ ] **App Store Connect account** - Developer account active
- [ ] **App ID created** - Bundle identifier registered
- [ ] **Certificates & Profiles** - Development and distribution certificates
- [ ] **App Store listing** - All metadata filled out
- [ ] **Pricing** - Free or paid (set price)
- [ ] **Availability** - Countries/regions selected

---

## Technical Requirements

### Code Signing & Build

- [ ] **Bundle Identifier** - Unique (e.g., com.yourcompany.dictation5x5)
- [ ] **Version number** - Semantic versioning (e.g., 1.0.0)
- [ ] **Build number** - Incremental for each submission
- [ ] **Code signing** - Distribution certificate configured
- [ ] **Provisioning profile** - App Store distribution profile
- [ ] **Archive build** - Successful archive in Xcode
- [ ] **Upload to App Store Connect** - Via Xcode or Transporter

### Capabilities & Permissions

- [ ] **Microphone permission** - NSMicrophoneUsageDescription in Info.plist
- [ ] **Network access** - Required for WebSocket connection
- [ ] **Background modes** (if needed) - Audio recording in background
- [ ] **Associated domains** (if using Sign in with Apple) - Configured

### Info.plist Requirements

- [ ] **NSMicrophoneUsageDescription** - "This app needs microphone access to transcribe your speech"
- [ ] **Privacy - Microphone Usage Description** - Same as above
- [ ] **Bundle display name** - User-facing app name
- [ ] **Bundle version** - Version string
- [ ] **LSRequiresIPhoneOS** - Set to true
- [ ] **UIRequiredDeviceCapabilities** - microphone, armv7

---

## Functionality Requirements

### Core Features

- [x] **Speech-to-text transcription** - Working
- [x] **Real-time transcription display** - Working
- [x] **Audio recording** - Working
- [x] **Session history** - Working
- [x] **Audio playback** - Working (needs testing)
- [ ] **User authentication** - NOT IMPLEMENTED
- [ ] **Cloud sync** (optional) - Sync transcripts across devices
- [ ] **Export transcripts** - Share/export functionality
- [ ] **Search transcripts** - Search history

### Error Handling

- [ ] **Network error handling** - Graceful handling of connection failures
- [ ] **Authentication errors** - Clear error messages
- [ ] **Permission denied** - Handle microphone permission denial
- [ ] **Server errors** - User-friendly error messages
- [ ] **Offline mode** - Handle no internet connection

### User Experience

- [ ] **Loading states** - Show progress during operations
- [ ] **Empty states** - Friendly messages when no data
- [ ] **Onboarding** - First-time user experience
- [ ] **Tutorial/Help** - Guide users on how to use app
- [ ] **Accessibility** - VoiceOver support, Dynamic Type
- [ ] **Dark mode support** - Adaptive colors for dark mode

---

## Data & Privacy (GDPR/CCPA Compliance)

### Data Collection

- [ ] **Privacy manifest** - Document all data collection
- [ ] **Data minimization** - Only collect necessary data
- [ ] **User consent** - Explicit consent for data collection
- [ ] **Data encryption** - Encrypt sensitive data in transit and at rest
- [ ] **Data deletion** - Ability to delete all user data
- [ ] **Data export** - Allow users to export their data

### Health Data (if applicable)

- [ ] **HealthKit integration** - If storing health-related transcripts
- [ ] **HIPAA compliance** - If handling PHI (Protected Health Information)
- [ ] **Health data permissions** - Request if needed

---

## Security Requirements

- [ ] **Secure authentication** - Use industry-standard auth (Firebase, Auth0)
- [ ] **Token management** - Secure storage of auth tokens
- [ ] **API security** - Secure WebSocket connections (WSS)
- [ ] **Data encryption** - Encrypt local storage
- [ ] **Certificate pinning** (optional) - For additional security
- [ ] **No hardcoded secrets** - Remove any API keys or secrets

---

## Testing Requirements

- [ ] **TestFlight beta testing** - Test with beta users
- [ ] **Device testing** - Test on multiple iOS versions
- [ ] **Network testing** - Test on various network conditions
- [ ] **Edge cases** - Test error scenarios
- [ ] **Performance testing** - Ensure app is responsive
- [ ] **Memory testing** - Check for memory leaks
- [ ] **Battery testing** - Ensure reasonable battery usage

---

## Missing from Current App

### Critical (Must Have)

1. **Real Authentication Implementation**
   - Currently only stubs in AuthManager.swift
   - Need Firebase Auth or similar
   - Sign in with Apple, Google, Email

2. **Privacy Policy & Terms**
   - No privacy policy URL
   - No terms of service
   - No support page

3. **User Account Management**
   - No sign out button in UI
   - No delete account functionality
   - No user profile/settings

4. **App Store Assets**
   - No app icon (1024x1024)
   - No screenshots
   - No app description

5. **Info.plist Configuration**
   - Need to verify microphone permission description
   - Need bundle identifier configuration

### Important (Should Have)

6. **Error Handling**
   - Better error messages
   - Offline handling
   - Network error recovery

7. **User Onboarding**
   - First-time user experience
   - Tutorial/help

8. **Data Management**
   - Export transcripts
   - Search functionality
   - Better data organization

9. **Accessibility**
   - VoiceOver support
   - Dynamic Type
   - Color contrast

10. **Performance**
    - Optimize for battery
    - Memory management
    - Background processing

---

## Implementation Priority

### Phase 1: Critical for App Store (Week 1)
1. Implement real authentication (Firebase Auth)
2. Add sign out and delete account buttons
3. Create privacy policy and terms pages
4. Add support page/contact
5. Configure Info.plist properly

### Phase 2: App Store Assets (Week 1)
1. Create app icon (1024x1024)
2. Take screenshots for all required sizes
3. Write app description
4. Set up App Store Connect listing

### Phase 3: Polish & Testing (Week 2)
1. Improve error handling
2. Add onboarding
3. TestFlight beta testing
4. Performance optimization

---

## Next Steps

1. **Choose authentication provider:**
   - Firebase Authentication (recommended - supports Apple, Google, Email)
   - Auth0 (alternative)
   - Custom backend (more work)

2. **Set up Firebase project:**
   - Create Firebase project
   - Enable Authentication
   - Configure Sign in with Apple
   - Configure Google Sign-In
   - Enable Email/Password auth

3. **Create legal pages:**
   - Host privacy policy online
   - Host terms of service online
   - Create support page

4. **Design app assets:**
   - App icon design
   - Screenshot preparation
   - Marketing materials

---

**Last Updated:** November 2025  
**Status:** Ready for implementation planning

