# GitHub Pages Setup Guide

## Overview

This guide will help you host the legal pages (Privacy Policy, Terms of Service, and Support) on GitHub Pages for free.

---

## Step 1: Create GitHub Repository (if not already done)

If you haven't already, create a repository on GitHub:
1. Go to https://github.com/new
2. Repository name: `dictation5x5` (or your preferred name)
3. Make it public (required for free GitHub Pages)
4. Click "Create repository"

---

## Step 2: Push Your Code to GitHub

If you haven't already pushed your code:

```bash
cd /Users/pratik/Documents/Dictation5x5
git add .
git commit -m "Add legal pages for GitHub Pages"
git push origin main
```

---

## Step 3: Make Repository Public (REQUIRED)

**IMPORTANT:** GitHub Pages on the free tier only works with **public repositories**. If your repository is private, you must make it public first.

1. **Go to Repository Settings:**
   - Navigate to: `https://github.com/YOUR_USERNAME/dictation5x5/settings`

2. **Scroll to "Danger Zone":**
   - Scroll all the way to the bottom of the settings page
   - Find the "Danger Zone" section

3. **Change Visibility:**
   - Click "Change visibility"
   - Select "Make public"
   - Type your repository name to confirm: `YOUR_USERNAME/dictation5x5`
   - Click "I understand, change repository visibility"

4. **Note:** Making the repository public is safe for this project since legal pages are meant to be publicly accessible anyway.

---

## Step 4: Enable GitHub Pages

1. **Go to your repository on GitHub:**
   - Navigate to: `https://github.com/YOUR_USERNAME/dictation5x5`

2. **Go to Settings:**
   - Click the "Settings" tab at the top of the repository

3. **Enable GitHub Pages:**
   - Scroll down to "Pages" in the left sidebar
   - **You should now see the "Source" dropdown** (if you don't, the repository might still be private)
   - Under "Source", select "Deploy from a branch"
   - Branch: `main` (or `master`)
   - Folder: `/docs`
   - Click "Save"

4. **Wait for deployment:**
   - GitHub will build and deploy your pages
   - This usually takes 1-2 minutes
   - You'll see a green checkmark when it's ready

---

## Step 4: Get Your GitHub Pages URL

After deployment, your pages will be available at:

```
https://YOUR_USERNAME.github.io/dictation5x5/
```

For example, if your GitHub username is `shprats`:
```
https://shprats.github.io/dictation5x5/
```

Your specific pages will be at:
- Privacy Policy: `https://YOUR_USERNAME.github.io/dictation5x5/privacy-policy.html`
- Terms of Service: `https://YOUR_USERNAME.github.io/dictation5x5/terms.html`
- Support: `https://YOUR_USERNAME.github.io/dictation5x5/support.html`

---

## Step 5: Update URLs in AppConfig.swift

1. **Open `Dictation5x5/AppConfig.swift` in Xcode**

2. **Replace the placeholder URLs:**

```swift
// Replace YOUR_USERNAME with your actual GitHub username
static let privacyPolicyURL = "https://YOUR_USERNAME.github.io/dictation5x5/privacy-policy.html"
static let termsOfServiceURL = "https://YOUR_USERNAME.github.io/dictation5x5/terms.html"
static let supportURL = "https://YOUR_USERNAME.github.io/dictation5x5/support.html"
```

**Example (if your username is `shprats`):**
```swift
static let privacyPolicyURL = "https://shprats.github.io/dictation5x5/privacy-policy.html"
static let termsOfServiceURL = "https://shprats.github.io/dictation5x5/terms.html"
static let supportURL = "https://shprats.github.io/dictation5x5/support.html"
```

3. **Build and test:**
   - Build the app (⌘B)
   - Run the app
   - Go to Settings → Legal & Support
   - Tap each link to verify they open correctly

---

## Step 6: Verify Everything Works

1. **Test the GitHub Pages URLs:**
   - Open each URL in a browser:
     - `https://YOUR_USERNAME.github.io/dictation5x5/privacy-policy.html`
     - `https://YOUR_USERNAME.github.io/dictation5x5/terms.html`
     - `https://YOUR_USERNAME.github.io/dictation5x5/support.html`

2. **Test from the app:**
   - Run the app
   - Go to Settings → Legal & Support
   - Tap each link
   - Should open in Safari and display the correct page

---

## Custom Domain (Optional)

If you want to use a custom domain (e.g., `dictation5x5.com`):

1. **In GitHub Pages Settings:**
   - Add your custom domain
   - Follow GitHub's instructions for DNS configuration

2. **Update AppConfig.swift:**
   - Use your custom domain URLs instead

---

## Updating Pages

To update the legal pages:

1. **Edit the HTML files in `docs/` folder:**
   - `docs/privacy-policy.html`
   - `docs/terms.html`
   - `docs/support.html`

2. **Commit and push:**
   ```bash
   git add docs/
   git commit -m "Update legal pages"
   git push origin main
   ```

3. **GitHub Pages will automatically update** (usually within 1-2 minutes)

---

## Troubleshooting

### Pages not loading
- Check that the repository is public (required for free GitHub Pages)
- Verify `/docs` folder is selected in Pages settings
- Wait a few minutes for initial deployment
- Check the "Actions" tab for deployment status

### 404 errors
- Verify file names match exactly (case-sensitive)
- Check that files are in the `docs/` folder
- Ensure files are committed and pushed to GitHub

### Links not working in app
- Verify URLs in `AppConfig.swift` are correct
- Check that URLs include `.html` extension
- Test URLs in a browser first
- Rebuild the app after updating URLs

---

## File Structure

Your repository should have this structure:

```
dictation5x5/
├── docs/
│   ├── index.html
│   ├── privacy-policy.html
│   ├── terms.html
│   └── support.html
├── Dictation5x5/
│   ├── AppConfig.swift
│   └── ... (other app files)
└── ... (other project files)
```

---

## Quick Reference

**GitHub Pages URL format:**
```
https://YOUR_USERNAME.github.io/REPOSITORY_NAME/
```

**Your specific URLs:**
- Home: `https://YOUR_USERNAME.github.io/dictation5x5/`
- Privacy: `https://YOUR_USERNAME.github.io/dictation5x5/privacy-policy.html`
- Terms: `https://YOUR_USERNAME.github.io/dictation5x5/terms.html`
- Support: `https://YOUR_USERNAME.github.io/dictation5x5/support.html`

---

**Last Updated:** November 2025

