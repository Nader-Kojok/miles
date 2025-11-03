# Mobile Features Implementation Guide

## 🎯 Overview

This document explains the implementation of push notifications, biometric authentication, and deep linking in the Bolide app using **Supabase-native** solutions (no Firebase required!).

## 📲 Push Notifications (Supabase + OneSignal)

### Why OneSignal instead of Firebase?

- ✅ **No additional backend needed** - OneSignal handles iOS (APNs) and Android (FCM) natively
- ✅ **Better integration with Supabase** - designed for non-Firebase apps
- ✅ **Free tier is generous** - 10,000 subscribers free
- ✅ **Admin dashboard included** - send notifications without code
- ✅ **Better developer experience** - simpler API than FCM

### Architecture

```
┌─────────────────┐
│  Admin Dashboard│  ──────→  Supabase Edge Function
│  (Next.js)      │                    │
└─────────────────┘                    ↓
                                  OneSignal API
                                       │
                              ┌────────┴────────┐
                              ↓                 ↓
                          iOS (APNs)     Android (FCM)
                              │                 │
                              └────────┬────────┘
                                       ↓
                              Flutter App receives
                              notification
                                       ↓
                              Saved to Supabase
                              notifications table
```

### Files Created

1. **`lib/services/push_notification_service.dart`**
   - Handles OneSignal initialization
   - Manages push notification permissions
   - Handles notification taps and foreground display
   - Integrates with existing Supabase notification system

2. **`supabase_notifications_schema.sql`**
   - Database schema for notifications
   - FCM tokens storage
   - RLS policies for security

### Setup Steps

#### 1. Create OneSignal Account

```bash
1. Go to https://onesignal.com
2. Create a free account
3. Create a new app
4. Get your APP_ID
5. Configure iOS (APNs) certificates
6. Configure Android (FCM) server key
```

#### 2. Add App ID to Flutter

```dart
// In main.dart
await PushNotificationService().initialize('YOUR_ONESIGNAL_APP_ID');
```

#### 3. Update Database

```bash
# Run the SQL migration
psql -h your-supabase-url -d postgres -f supabase_notifications_schema.sql
```

#### 4. Admin Dashboard Integration

Create a Supabase Edge Function to send notifications:

```typescript
// supabase/functions/send-notification/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const ONESIGNAL_API_KEY = Deno.env.get('ONESIGNAL_API_KEY')
const ONESIGNAL_APP_ID = Deno.env.get('ONESIGNAL_APP_ID')

serve(async (req) => {
  const { userIds, title, message, type, data } = await req.json()

  // Send via OneSignal
  const response = await fetch('https://onesignal.com/api/v1/notifications', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Basic ${ONESIGNAL_API_KEY}`,
    },
    body: JSON.stringify({
      app_id: ONESIGNAL_APP_ID,
      include_external_user_ids: userIds,
      headings: { en: title },
      contents: { en: message },
      data: { type, ...data },
    }),
  })

  return new Response(JSON.stringify(await response.json()), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

### Notification Types

```typescript
enum NotificationType {
  'order_update',    // Order status changed
  'promotion',       // New promotion available
  'price_drop',      // Product price dropped
  'back_in_stock',   // Product back in stock
  'custom',          // Admin custom message
}
```

### Usage Examples

```dart
// Initialize in main.dart
await PushNotificationService().initialize('YOUR_APP_ID');

// Add user tags for segmentation
await PushNotificationService().addTag('user_type', 'premium');
await PushNotificationService().addTag('interests', 'brakes');

// Check permission status
bool hasPermission = await PushNotificationService().getPermissionStatus();

// Request permission manually
bool granted = await PushNotificationService().requestPermission();

// Disable notifications
await PushNotificationService().setPushEnabled(false);

// Logout (clear association)
await PushNotificationService().logout();
```

## 🔐 Biometric Authentication

### Features

- Face ID (iOS)
- Touch ID (iOS)
- Fingerprint (Android)
- Quick login
- Secure checkout

### Package: `local_auth`

```dart
// Check if biometrics are available
bool canAuthenticate = await auth.canCheckBiometrics;

// Authenticate
bool authenticated = await auth.authenticate(
  localizedReason: 'Please authenticate to continue',
  options: const AuthenticationOptions(
    biometricOnly: true,
    stickyAuth: true,
  ),
);
```

## 🔗 Deep Linking

### Features

- Universal Links (iOS)
- App Links (Android)
- Product sharing
- Order tracking
- Marketing campaigns

### Package: `app_links`

```dart
// Initialize
final _appLinks = AppLinks();

// Listen to incoming links
_appLinks.uriLinkStream.listen((uri) {
  // Handle: bolide://product/123
  // Handle: https://bolide.app/product/123
});

// Get initial link (app opened via link)
final uri = await _appLinks.getInitialLink();
```

### URL Schemes

```
bolide://product/{id}
bolide://order/{id}
bolide://category/{slug}
bolide://search?q=brake+pads
```

## 📱 Admin Dashboard Features

### Notification Panel

Create a new page in admin dashboard: `/app/dashboard/notifications/page.tsx`

#### Features:
1. **Send Custom Notifications**
   - Select target users (all, specific, by criteria)
   - Choose notification type
   - Add title, message, and image
   - Schedule for later

2. **Notification Templates**
   - Order status updates
   - Price drop alerts
   - Promotional offers
   - Back in stock

3. **Analytics**
   - Delivery rate
   - Open rate
   - Click-through rate
   - Conversions

4. **Notification History**
   - View sent notifications
   - Resend failed notifications
   - Track performance

### API Endpoints

```typescript
// Send notification
POST /api/notifications/send
Body: {
  userIds?: string[],        // Optional: specific users
  segment?: 'all' | 'active' | 'inactive',
  title: string,
  message: string,
  type: NotificationType,
  data?: object,
  scheduledFor?: Date,
}

// Get notification stats
GET /api/notifications/stats?notificationId={id}

// Get notification history
GET /api/notifications/history?page=1&limit=20
```

## 🚀 Implementation Checklist

### Phase 1: Push Notifications (Week 1)
- [x] Add OneSignal package to pubspec.yaml
- [ ] Create OneSignal account and get APP_ID
- [ ] Configure iOS APNs certificates
- [ ] Configure Android FCM server key
- [ ] Run database migration
- [ ] Initialize PushNotificationService in main.dart
- [ ] Test on iOS device
- [ ] Test on Android device

### Phase 2: Admin Dashboard (Week 2)
- [ ] Create Supabase Edge Function for sending notifications
- [ ] Create notification panel UI in admin dashboard
- [ ] Implement notification templates
- [ ] Add user segmentation
- [ ] Implement notification scheduling
- [ ] Add analytics dashboard

### Phase 3: Biometric Auth (Week 3)
- [ ] Implement biometric login
- [ ] Add biometric checkout
- [ ] Store biometric preference
- [ ] Handle fallback to password

### Phase 4: Deep Linking (Week 4)
- [ ] Configure iOS Universal Links
- [ ] Configure Android App Links
- [ ] Implement link handling
- [ ] Add share functionality
- [ ] Test marketing links

## 📝 Notes

### Why Not Firebase?

1. **Redundancy**: Supabase already provides backend, auth, and database
2. **Complexity**: Firebase adds another service to manage
3. **Cost**: Firebase has usage limits; OneSignal is more generous
4. **Integration**: OneSignal is built for non-Firebase apps
5. **Admin Dashboard**: OneSignal provides built-in notification sending

### Best Practices

1. **Always request permission at the right time** - not on app launch
2. **Use user segmentation** - don't spam all users
3. **Test thoroughly** - notifications are tricky on iOS
4. **Handle notification taps** - always navigate to relevant content
5. **Save to database** - keep notification history in Supabase
6. **Respect user preferences** - allow opting out

### Security Considerations

1. **RLS Policies**: Users can only see their own notifications
2. **Admin-only sending**: Only admins can create notifications
3. **Token storage**: FCM tokens are securely stored in Supabase
4. **Data encryption**: Use HTTPS for all API calls
5. **Permission checks**: Always verify user permissions

## 🔧 Troubleshooting

### iOS Issues
- Ensure APNs certificates are valid
- Check Info.plist for required permissions
- Test on physical device (simulator doesn't support push)

### Android Issues
- Verify FCM server key
- Check AndroidManifest.xml permissions
- Ensure Google Play Services are available

### OneSignal Issues
- Verify APP_ID is correct
- Check dashboard for delivery errors
- Ensure user is logged in with correct ID

## 📚 Resources

- [OneSignal Flutter SDK](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [local_auth Package](https://pub.dev/packages/local_auth)
- [app_links Package](https://pub.dev/packages/app_links)
- [Push Notification Best Practices](https://onesignal.com/blog/push-notification-best-practices/)
