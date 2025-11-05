# iOS App Installation Guide - Run Without Xcode

## The Problem

Your app stops working when Xcode is closed because you're using a **Free Apple Developer Account** (Personal Team), which has these limitations:

- ⏰ **Provisioning profiles expire after 7 days**
- 📱 **Limited to 3 test devices per platform**
- 🔄 **Requires rebuilding and reinstalling every 7 days**
- 🐛 **App only works while debugger is attached (in some cases)**

## Solutions

### Option 1: Rebuild Every 7 Days (Free - Current Method)

**What's happening:**
- Free provisioning profiles expire after 7 days
- You must rebuild and reinstall the app every week

**Steps to reinstall:**
```bash
# Connect your iPhone to Mac
# Run from your project directory
flutter clean
flutter build ios --release
flutter install -d <your-device-id>

# OR open in Xcode
open ios/Runner.xcworkspace
# Then: Product > Run (Cmd+R)
```

**To find your device ID:**
```bash
flutter devices
```

---

### Option 2: Apple Developer Program ($99/year) ⭐ RECOMMENDED

**Benefits:**
- ✅ Apps work permanently (until certificate expires in 1 year)
- ✅ No need to keep Xcode running
- ✅ TestFlight for beta testing (up to 10,000 testers)
- ✅ App Store distribution
- ✅ Up to 100 test devices
- ✅ Push notifications, iCloud, etc.

**How to enroll:**
1. Go to https://developer.apple.com/programs/enroll/
2. Pay $99 USD (annual fee)
3. Wait for approval (usually 24-48 hours)
4. Update Xcode signing with your paid account

**After enrollment, rebuild your app:**
```bash
# Update signing in Xcode
open ios/Runner.xcworkspace
# Go to: Runner > Signing & Capabilities
# Select your paid developer team
# Then rebuild
flutter clean
flutter build ios --release
```

---

### Option 3: Ad Hoc Distribution (Requires Paid Account)

**For sharing with specific testers (up to 100 devices):**

#### Step 1: Get Device UDIDs
Ask testers to:
1. Connect iPhone to Mac
2. Open Finder > Select iPhone
3. Click on device info until UDID appears
4. Copy UDID

**OR** use https://udid.tech (easier for testers)

#### Step 2: Register Devices
1. Go to https://developer.apple.com/account/resources/devices/list
2. Click "+" to add device
3. Enter device name and UDID
4. Save

#### Step 3: Build Archive
```bash
# Build release version
flutter build ios --release

# Open Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Product > Archive
# 2. Wait for archive to complete
# 3. Window > Organizer (or it opens automatically)
```

#### Step 4: Distribute App
In Xcode Organizer:
1. Select your archive
2. Click "Distribute App"
3. Choose "Ad Hoc"
4. Select your distribution certificate
5. Choose "Export" and save IPA file

#### Step 5: Share IPA with Testers

**Method A: Using Diawi (Easiest)**
1. Go to https://www.diawi.com
2. Upload your IPA file
3. Click "Send"
4. Share the generated link with testers
5. Testers open link in Safari on their iPhone
6. Tap "Install" button

**Method B: Using Apple Configurator 2**
1. Install Apple Configurator 2 from Mac App Store
2. Connect tester's device
3. Drag and drop IPA file onto device
4. App installs directly

**Method C: Using Xcode**
1. Connect tester's device to your Mac
2. Window > Devices and Simulators
3. Select device
4. Click "+" under Installed Apps
5. Select your IPA file

---

### Option 4: TestFlight (Requires Paid Account)

**Best for beta testing multiple users:**

#### Step 1: Build and Archive
```bash
flutter build ios --release
open ios/Runner.xcworkspace
# Product > Archive
```

#### Step 2: Upload to App Store Connect
1. In Organizer, select archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Upload

#### Step 3: Add Testers
1. Go to https://appstoreconnect.apple.com
2. My Apps > Your App > TestFlight
3. Add internal testers (up to 100)
4. Add external testers (up to 10,000) - requires Apple review

#### Step 4: Testers Install
1. Testers install TestFlight app from App Store
2. They receive invitation email
3. Open invitation and install your app
4. App updates automatically when you upload new builds

---

## Quick Comparison

| Method | Cost | Duration | Devices | Xcode Required |
|--------|------|----------|---------|----------------|
| Free Account | $0 | 7 days | 3 | Yes (for rebuild) |
| Paid Account | $99/year | 1 year | 100 | No (after install) |
| Ad Hoc | $99/year | 1 year | 100 | No (after install) |
| TestFlight | $99/year | 90 days/build | 10,000 | No (after upload) |

---

## Recommended Workflow

### For Personal Testing (Just You)
- **Free Account**: Rebuild every 7 days
- **Cost**: $0
- **Effort**: Low (5 minutes weekly)

### For Small Team (2-10 people)
- **Paid Account + Ad Hoc Distribution**
- **Cost**: $99/year
- **Effort**: Medium (rebuild when needed)

### For Beta Testing (10+ people)
- **Paid Account + TestFlight**
- **Cost**: $99/year
- **Effort**: Low (automatic updates)

### For Production
- **Paid Account + App Store**
- **Cost**: $99/year
- **Effort**: High (App Store review process)

---

## Current Issue: App Stops When Xcode Closes

This happens because:
1. **Free provisioning profile** is in "debug" mode
2. App is attached to Xcode debugger
3. When Xcode closes, debugger detaches and app may crash

**Immediate Fix:**
Build in **Release mode** instead of Debug:
```bash
# Instead of: flutter run
# Use:
flutter run --release

# Or build and install:
flutter build ios --release
flutter install
```

**Release mode apps:**
- ✅ Work without Xcode running
- ✅ Better performance
- ❌ Still expire after 7 days (free account)
- ❌ Can't use debugger

---

## Enable Developer Mode on iPhone

For iOS 16+, testers must enable Developer Mode:

1. Settings > Privacy & Security > Developer Mode
2. Toggle ON
3. Restart iPhone
4. Confirm when prompted

---

## Troubleshooting

### "App is no longer available"
- Provisioning profile expired (7 days for free account)
- **Solution**: Rebuild and reinstall

### "Untrusted Developer"
1. Settings > General > VPN & Device Management
2. Tap your developer profile
3. Tap "Trust"

### "Unable to Install"
- Device UDID not registered
- **Solution**: Add device to developer portal

### App crashes immediately
- Built in Debug mode without Xcode
- **Solution**: Build with `--release` flag

---

## My Recommendation for You

Based on your situation:

**Short-term (Free):**
```bash
# Build release version every 7 days
flutter clean
flutter build ios --release
open ios/Runner.xcworkspace
# Product > Run
```

**Long-term (Best):**
1. **Enroll in Apple Developer Program** ($99/year)
2. **Use TestFlight** for testing
3. **Publish to App Store** when ready

The $99/year investment is worth it if:
- ✅ You're serious about iOS development
- ✅ You have multiple testers
- ✅ You want to publish to App Store
- ✅ You don't want to rebuild every week

---

## Next Steps

1. **Decide which option fits your needs**
2. **For free account**: Build with `--release` flag
3. **For paid account**: Enroll at https://developer.apple.com/programs/
4. **For distribution**: Follow Ad Hoc or TestFlight steps above

Need help? Check:
- Apple Developer Support: https://developer.apple.com/support/
- Flutter iOS Deployment: https://docs.flutter.dev/deployment/ios
