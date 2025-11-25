# Quick Setup Guide

## Adding New Files to Xcode Project

After pulling these changes, you need to add the new Swift files to your Xcode project:

1. **Open the project in Xcode:**
   ```bash
   open Dictation5x5.xcodeproj
   ```

2. **Add the new files:**
   - Right-click on the `Dictation5x5` folder in the Project Navigator
   - Select "Add Files to Dictation5x5..."
   - Select these files:
     - `ServerConfig.swift`
     - `SettingsView.swift`
   - Make sure "Copy items if needed" is **unchecked** (files are already in the project directory)
   - Make sure "Add to targets: Dictation5x5" is **checked**
   - Click "Add"

3. **Verify the files are added:**
   - Check that `ServerConfig.swift` and `SettingsView.swift` appear in the Project Navigator
   - Try building the project (⌘B) to ensure there are no compilation errors

## Testing the Integration

1. **Start the Python server:**
   ```bash
   cd /Users/pratik/Documents/Dictation5x5
   python speech_server.py
   ```

2. **Run the iOS app:**
   - Build and run in Xcode (⌘R)
   - Tap the settings (gear) icon
   - Verify the server URL is set correctly (default: `ws://localhost:8080`)
   - Tap "Start" to begin recording

## Troubleshooting

- **"Cannot find 'ServerConfig' in scope"**: Make sure `ServerConfig.swift` is added to the Xcode project target
- **"Cannot find 'SettingsView' in scope"**: Make sure `SettingsView.swift` is added to the Xcode project target
- **Build errors**: Clean build folder (⌘⇧K) and rebuild (⌘B)

