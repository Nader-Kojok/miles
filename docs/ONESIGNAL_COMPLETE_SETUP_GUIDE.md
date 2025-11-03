# OneSignal Complete Setup Guide
## Following Official Documentation

Based on: https://documentation.onesignal.com/docs/en/flutter-sdk-setup

---

## ✅ Step 1: Configure iOS APNs (Apple Push Notification Service)

### Generate .p8 Authentication Key

1. **Log into Apple Developer Account**
   ```
   https://developer.apple.com/account/
   ```

2. **Navigate to Keys**
   ```
   Certificates, Identifiers & Profiles → Keys
   https://developer.apple.com/account/resources/authkeys
   ```

3. **Create New Key**
   - Click the blue **+** button
   - Enter name: `Bolide Push Notifications`
   - Check: **Apple Push Notifications service (APNs)**
   - Click **Continue**, then **Register**

4. **Download .p8 File**
   - ⚠️ **IMPORTANT**: Download immediately - you can't download it again!
   - Save it securely (e.g., `AuthKey_XXXXXXXXXX.p8`)
   - Note the **Key ID** (10 characters, e.g., `AB12CD34EF`)

5. **Get Your Team ID**
   - Go to: https://developer.apple.com/account/
   - Find **Team ID** in top-right corner (10 characters)

6. **Get Your Bundle ID**
   - Option A: Xcode → Runner target → Signing & Capabilities
   - Option B: https://developer.apple.com/account/resources/identifiers/list
   - Should be: `com.agencearcane.bolide`

---

### Upload .p8 to OneSignal

1. **Go to OneSignal Dashboard**
   ```
   https://dashboard.onesignal.com/apps/924c65ff-2ef3-4dfb-ab0c-a101adda03f8/settings/platforms
   ```

2. **Configure Apple iOS (APNs)**
   - Click **Apple iOS (APNs)** section
   - Select **.p8 Auth Key (Recommended)**

3. **Fill in Details**
   - **.p8 File**: Upload your `AuthKey_XXXXXXXXXX.p8`
   - **Key ID**: Enter the 10-character Key ID
   - **Team ID**: Enter your 10-character Team ID
   - **App Bundle ID**: `com.agencearcane.bolide`

4. **Save Configuration**

---

## ✅ Step 2: Configure iOS in Xcode

### Open Your Project

```bash
cd /opt/homebrew/var/www/bolide/bolide
open ios/Runner.xcworkspace
```

⚠️ **IMPORTANT**: Open `.xcworkspace`, NOT `.xcodeproj`!

---

### 1. Add Push Notifications Capability

1. Select **Runner** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **Push Notifications**

---

### 2. Add Background Modes Capability

1. Still in **Signing & Capabilities**
2. Click **+ Capability**
3. Add **Background Modes**
4. Check: ☑️ **Remote notifications**

---

### 3. Add App Group

1. Still in **Signing & Capabilities**
2. Click **+ Capability**
3. Add **App Groups**
4. Click **+** to add new container
5. Enter: `group.com.agencearcane.bolide.onesignal`
   - Format: `group.[YOUR_BUNDLE_ID].onesignal`
   - Keep `group.` prefix and `.onesignal` suffix!

---

### 4. Add Notification Service Extension (NSE)

This is needed for rich notifications (images, badges, analytics).

1. **Create Extension**
   - In Xcode: **File → New → Target...**
   - Select **Notification Service Extension**
   - Click **Next**

2. **Configure Extension**
   - Product Name: `OneSignalNotificationServiceExtension`
   - Language: Swift
   - Click **Finish**

3. **Don't Activate Scheme**
   - When prompted "Activate scheme?", click **Don't Activate**

4. **Set Deployment Target**
   - Select `OneSignalNotificationServiceExtension` target
   - Set **iOS Deployment Target** to match your app (iOS 13.0 or higher)

---

### 5. Add NSE to App Group

1. Select **OneSignalNotificationServiceExtension** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **App Groups**
5. Check the SAME group: `group.com.agencearcane.bolide.onesignal`

---

### 6. Update NSE Code

1. **Open** `OneSignalNotificationServiceExtension/NotificationService.swift`

2. **Replace ALL content** with:

```swift
import UserNotifications
import OneSignalExtension

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            OneSignalExtension.didReceiveNotificationExtensionRequest(self.receivedRequest, with: bestAttemptContent, withContentHandler: self.contentHandler)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            OneSignalExtension.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
}
```

---

### 7. Add OneSignal to NSE Target

1. **Open Podfile** (`ios/Podfile`)

2. **Add NSE target** at the end of the file:

```ruby
target 'OneSignalNotificationServiceExtension' do
  use_frameworks!
  pod 'OneSignalXCFramework', '>= 5.0.0', '< 6.0'
end
```

3. **Install Pods**

```bash
cd ios
pod install
cd ..
```

---

## ✅ Step 3: Configure Android (Optional but Recommended)

### Update AndroidManifest.xml

1. **Open** `android/app/src/main/AndroidManifest.xml`

2. **Add permissions** (if not already present):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application>
        <!-- Your existing application code -->
    </application>
</manifest>
```

### Configure Firebase (for Android)

OneSignal uses Firebase Cloud Messaging (FCM) for Android.

1. **Go to OneSignal Dashboard**
   ```
   https://dashboard.onesignal.com/apps/924c65ff-2ef3-4dfb-ab0c-a101adda03f8/settings/platforms
   ```

2. **Configure Google Android (FCM)**
   - Click **Google Android (FCM)**
   - Option 1: Let OneSignal handle it (easiest)
   - Option 2: Upload your own `google-services.json`

---

## ✅ Step 4: Test Your Setup

### Build and Run on iPhone

```bash
# Clean build
flutter clean
flutter pub get

# Build for iOS
cd ios
pod install
cd ..

# Run on your iPhone
flutter run -d 00008110-0015648621A1801E
```

### Check OneSignal Dashboard

1. **Open app on your iPhone**
   - App should request notification permission
   - Accept the permission

2. **Verify Subscription**
   ```
   https://dashboard.onesignal.com/apps/924c65ff-2ef3-4dfb-ab0c-a101adda03f8/audience/subscriptions
   ```
   - You should see a new subscription with status: **Subscribed**
   - Platform: **iOS**

### Send Test Notification

1. **Go to Messages**
   ```
   https://dashboard.onesignal.com/apps/924c65ff-2ef3-4dfb-ab0c-a101adda03f8/messages/new
   ```

2. **Create New Message**
   - Audience: **Subscribed Users**
   - Title: `Test Notification`
   - Message: `This is a test from OneSignal!`
   - Click **Send Message**

3. **Check Your iPhone**
   - You should receive the notification!
   - Tap it to open the app

---

## ✅ Step 5: Get REST API Key (for Admin Dashboard)

1. **Go to Settings**
   ```
   https://dashboard.onesignal.com/apps/924c65ff-2ef3-4dfb-ab0c-a101adda03f8/settings/keys-ids
   ```

2. **Copy REST API Key**
   - Find **REST API Key** (starts with `OS...`)
   - Copy the entire key

3. **Add to Admin Dashboard**

```bash
cd admin-dashboard

# Create .env.local if it doesn't exist
cp .env.example .env.local

# Edit .env.local
nano .env.local
```

4. **Add Keys**

```env
NEXT_PUBLIC_SUPABASE_URL=https://uerwlrpatvumjdksfgbj.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVlcndscnBhdHZ1bWpka3NmZ2JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MzczNTEsImV4cCI6MjA3NzQxMzM1MX0.Q_TykGHuIEMyhOvf2OfmDh7PQbk54cZehNJKnc4CWYg

ONESIGNAL_APP_ID=924c65ff-2ef3-4dfb-ab0c-a101adda03f8
ONESIGNAL_REST_API_KEY=YOUR_REST_API_KEY_HERE
```

5. **Restart Admin Dashboard**

```bash
npm run dev
```

---

## ✅ Step 6: Apply Database Schemas

### Run SQL Migrations

1. **Open Supabase SQL Editor**
   ```
   https://supabase.com/dashboard/project/uerwlrpatvumjdksfgbj/sql/new
   ```

2. **Run First Schema** (User Notifications)
   - Copy contents of `supabase_notifications_schema.sql`
   - Paste in SQL editor
   - Click **Run**

3. **Run Second Schema** (Admin History)
   - Copy contents of `supabase_admin_notifications_schema.sql`
   - Paste in SQL editor
   - Click **Run**

4. **Verify Tables Created**
   - Go to Table Editor
   - You should see:
     - `notifications`
     - `fcm_tokens`
     - `admin_notifications`

---

## ✅ Step 7: Test Admin Dashboard

1. **Start Admin Dashboard**
   ```bash
   cd admin-dashboard
   npm run dev
   ```

2. **Open Notifications Page**
   ```
   http://localhost:3000/dashboard/notifications
   ```

3. **Send Test Notification**
   - Click **Nouvelle notification**
   - Title: `Test from Admin`
   - Message: `This is sent from the admin dashboard!`
   - Click **Envoyer maintenant**

4. **Check Your iPhone**
   - You should receive the notification!

---

## 🎯 Checklist

### iOS Setup
- [ ] Generated .p8 key in Apple Developer
- [ ] Uploaded .p8 to OneSignal dashboard
- [ ] Added Push Notifications capability
- [ ] Added Background Modes capability
- [ ] Created App Group
- [ ] Created Notification Service Extension
- [ ] Added NSE to App Group
- [ ] Updated NSE code
- [ ] Added OneSignal to NSE in Podfile
- [ ] Ran `pod install`

### Android Setup
- [ ] Added POST_NOTIFICATIONS permission
- [ ] Configured FCM in OneSignal

### Testing
- [ ] App builds successfully
- [ ] App requests notification permission
- [ ] Device appears in OneSignal dashboard
- [ ] Test notification received
- [ ] Notification tap opens app

### Admin Dashboard
- [ ] Got REST API Key
- [ ] Added to .env.local
- [ ] Applied database schemas
- [ ] Admin panel loads
- [ ] Can send notifications
- [ ] Notifications appear in history

---

## 🐛 Troubleshooting

### iOS: "No Provisioning Profile"

**Solution**: In Xcode, select Runner target → Signing & Capabilities → Enable "Automatically manage signing"

### iOS: Notification Not Received

1. Check device is subscribed in OneSignal dashboard
2. Verify .p8 key is correct
3. Check App Group name matches exactly
4. Ensure NSE has OneSignal pod installed
5. Test on physical device (simulator doesn't support push)

### Android: Notification Not Received

1. Verify FCM is configured in OneSignal
2. Check POST_NOTIFICATIONS permission granted
3. Test on Android 13+ device

### Admin Dashboard: "Unauthorized"

1. Verify you're logged in as admin
2. Check `is_admin = true` in profiles table
3. Verify REST API Key is correct

---

## 📚 Official Documentation Links

- [Flutter SDK Setup](https://documentation.onesignal.com/docs/en/flutter-sdk-setup)
- [iOS .p8 Setup](https://documentation.onesignal.com/docs/en/ios-p8-token-based-connection-to-apns)
- [Android FCM Setup](https://documentation.onesignal.com/docs/en/android-firebase-credentials)
- [OneSignal API Reference](https://documentation.onesignal.com/reference/create-message)
- [OneSignal Dashboard](https://dashboard.onesignal.com)

---

## ✨ You're All Set!

Once you complete all steps, you'll have:

- ✅ Push notifications working on iOS
- ✅ Push notifications working on Android
- ✅ Admin dashboard to send custom notifications
- ✅ Notification history tracking
- ✅ User segmentation capabilities
- ✅ Rich notifications with images and deep links

**Your OneSignal App ID**: `924c65ff-2ef3-4dfb-ab0c-a101adda03f8`

**Dashboard**: https://dashboard.onesignal.com/apps/924c65ff-2ef3-4dfb-ab0c-a101adda03f8
