# Mobile Features - Quick Start Guide

## ✅ What's Been Implemented

### 1. 📲 Push Notifications (OneSignal + Supabase)
- **Service**: `lib/services/push_notification_service.dart`
- **Status**: ✅ Configured with APP_ID: `924c65ff-2ef3-4dfb-ab0c-a101adda03f8`
- **Initialized**: Yes, in `main.dart`

### 2. 🔐 Biometric Authentication
- **Service**: `lib/services/biometric_auth_service.dart`
- **Features**: Face ID, Touch ID, Fingerprint
- **Status**: ✅ Ready to use

### 3. 🔗 Deep Linking
- **Service**: `lib/services/deep_link_service.dart`
- **Supports**: Universal Links (iOS) + App Links (Android)
- **Status**: ✅ Ready to use

### 4. 💾 Database Schema
- **File**: `supabase_notifications_schema.sql`
- **Status**: ⚠️ Needs to be applied to Supabase

---

## 🚀 Next Steps

### Step 1: Apply Database Schema (5 minutes)

1. Open Supabase SQL Editor:
   ```
   https://supabase.com/dashboard/project/uerwlrpatvumjdksfgbj/sql/new
   ```

2. Copy contents of `supabase_notifications_schema.sql`

3. Paste and run in SQL editor

4. Verify tables created:
   - `notifications`
   - `fcm_tokens`

### Step 2: Configure iOS for Push Notifications (10 minutes)

1. **Open Xcode**: `ios/Runner.xcworkspace`

2. **Add Capability**:
   - Select Runner target
   - Go to "Signing & Capabilities"
   - Click "+ Capability"
   - Add "Push Notifications"

3. **Update Info.plist** (`ios/Runner/Info.plist`):
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>remote-notification</string>
   </array>
   ```

4. **Configure OneSignal iOS**:
   - Go to OneSignal dashboard
   - Settings → Platforms → Apple iOS (APNs)
   - Upload your APNs certificate or key

### Step 3: Configure Android for Push Notifications (5 minutes)

1. **Update AndroidManifest.xml** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <manifest>
       <uses-permission android:name="android.permission.INTERNET"/>
       <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   </manifest>
   ```

2. **Configure OneSignal Android**:
   - Go to OneSignal dashboard
   - Settings → Platforms → Google Android (FCM)
   - Add your Firebase Server Key (or use OneSignal's FCM)

### Step 4: Configure Deep Linking

#### iOS Universal Links

1. **Create `apple-app-site-association` file** on your domain:
   ```json
   {
     "applinks": {
       "apps": [],
       "details": [{
         "appID": "TEAM_ID.com.agencearcane.bolide",
         "paths": ["*"]
       }]
     }
   }
   ```

2. **Host at**: `https://bolide.app/.well-known/apple-app-site-association`

3. **Add Associated Domains in Xcode**:
   - Signing & Capabilities → + Capability → Associated Domains
   - Add: `applinks:bolide.app`

#### Android App Links

1. **Update AndroidManifest.xml**:
   ```xml
   <intent-filter android:autoVerify="true">
       <action android:name="android.intent.action.VIEW" />
       <category android:name="android.intent.category.DEFAULT" />
       <category android:name="android.intent.category.BROWSABLE" />
       <data android:scheme="https" android:host="bolide.app" />
       <data android:scheme="bolide" />
   </intent-filter>
   ```

2. **Create `assetlinks.json`** on your domain:
   ```json
   [{
     "relation": ["delegate_permission/common.handle_all_urls"],
     "target": {
       "namespace": "android_app",
       "package_name": "com.agencearcane.bolide",
       "sha256_cert_fingerprints": ["YOUR_SHA256_FINGERPRINT"]
     }
   }]
   ```

3. **Host at**: `https://bolide.app/.well-known/assetlinks.json`

---

## 📱 Usage Examples

### Push Notifications

```dart
// Already initialized in main.dart!

// Check permission
bool hasPermission = await PushNotificationService().getPermissionStatus();

// Request permission
bool granted = await PushNotificationService().requestPermission();

// Add user tags for segmentation
await PushNotificationService().addTag('user_type', 'premium');
await PushNotificationService().addTag('favorite_category', 'brakes');

// Disable notifications
await PushNotificationService().setPushEnabled(false);
```

### Biometric Authentication

```dart
// Check if available
bool canAuth = await BiometricAuthService().canCheckBiometrics();

// Get available types
List<BiometricType> types = await BiometricAuthService().getAvailableBiometrics();

// Authenticate for login
bool authenticated = await BiometricAuthService().authenticateForLogin();

// Authenticate for checkout
bool authenticated = await BiometricAuthService().authenticateForCheckout();

// Enable/disable biometric login
bool enabled = await BiometricAuthService().toggleBiometric();
```

### Deep Linking

```dart
// Initialize in main.dart or app startup
await DeepLinkService().initialize();

// Listen to incoming links
DeepLinkService().linkStream.listen((uri) {
  final route = DeepLinkService().parseDeepLink(uri);
  
  if (route != null) {
    switch (route.type) {
      case DeepLinkType.product:
        // Navigate to product detail
        Navigator.pushNamed(context, '/product/${route.id}');
        break;
      case DeepLinkType.order:
        // Navigate to order detail
        Navigator.pushNamed(context, '/order/${route.id}');
        break;
      case DeepLinkType.search:
        // Navigate to search with query
        Navigator.pushNamed(context, '/search?q=${route.query}');
        break;
      // ... handle other types
    }
  }
});

// Generate shareable links
String productLink = DeepLinkService().generateProductLink('product-123');
String categoryLink = DeepLinkService().generateCategoryLink('brakes');
String searchLink = DeepLinkService().generateSearchLink('brake pads');
```

---

## 🎯 Testing Checklist

### Push Notifications
- [ ] Request permission on first launch
- [ ] Receive notification when app is in foreground
- [ ] Receive notification when app is in background
- [ ] Receive notification when app is closed
- [ ] Tap notification opens correct screen
- [ ] Notification saved to database
- [ ] Unread count updates correctly

### Biometric Authentication
- [ ] Check if device supports biometrics
- [ ] Authenticate with Face ID (iOS)
- [ ] Authenticate with Touch ID (iOS)
- [ ] Authenticate with Fingerprint (Android)
- [ ] Enable biometric login in settings
- [ ] Login with biometrics works
- [ ] Checkout with biometrics works

### Deep Linking
- [ ] Open app via custom scheme: `bolide://product/123`
- [ ] Open app via universal link: `https://bolide.app/product/123`
- [ ] Navigate to correct screen
- [ ] Share product link works
- [ ] Share category link works
- [ ] Email marketing links work

---

## 🔧 Troubleshooting

### Push Notifications Not Working

**iOS:**
- Ensure APNs certificate is valid in OneSignal dashboard
- Check Info.plist has `UIBackgroundModes`
- Test on physical device (simulator doesn't support push)
- Check Xcode console for OneSignal logs

**Android:**
- Verify FCM server key in OneSignal dashboard
- Check AndroidManifest.xml has POST_NOTIFICATIONS permission
- Ensure Google Play Services are available
- Check Logcat for OneSignal logs

### Biometric Not Working

- Check device has biometrics enrolled
- Verify Info.plist (iOS) has Face ID usage description
- Test on physical device
- Check permission dialogs appear

### Deep Links Not Opening App

**iOS:**
- Verify `apple-app-site-association` file is accessible
- Check Associated Domains in Xcode
- Test with Safari (not Chrome)
- Use Apple's validator: https://search.developer.apple.com/appsearch-validation-tool/

**Android:**
- Verify `assetlinks.json` file is accessible
- Check intent-filter in AndroidManifest.xml
- Test with `adb shell am start -a android.intent.action.VIEW -d "https://bolide.app/product/123"`

---

## 📚 Additional Resources

- [OneSignal Flutter Setup](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [local_auth Package](https://pub.dev/packages/local_auth)
- [app_links Package](https://pub.dev/packages/app_links)
- [iOS Universal Links](https://developer.apple.com/ios/universal-links/)
- [Android App Links](https://developer.android.com/training/app-links)

---

## 🎉 What's Next?

1. **Apply database schema** to Supabase
2. **Test push notifications** on your iPhone
3. **Test biometric authentication**
4. **Configure deep linking** for your domain
5. **Build admin dashboard notification panel** (next task!)

All the core mobile features are now implemented and ready to use! 🚀
