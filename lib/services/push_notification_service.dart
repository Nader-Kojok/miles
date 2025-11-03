import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Push Notification Service using OneSignal
/// OneSignal handles all push notification complexity for iOS/Android
/// Integrates seamlessly with Supabase
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final _supabase = Supabase.instance.client;
  bool _initialized = false;

  /// Initialize OneSignal push notifications
  /// oneSignalAppId: Get this from https://onesignal.com dashboard
  Future<void> initialize(String oneSignalAppId) async {
    if (_initialized) return;

    try {
      // Initialize OneSignal
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(oneSignalAppId);

      // Request permission (iOS)
      await OneSignal.Notifications.requestPermission(true);

      // Handle notification opened
      OneSignal.Notifications.addClickListener(_handleNotificationOpened);

      // Handle notification received (foreground)
      OneSignal.Notifications.addForegroundWillDisplayListener(_handleNotificationReceived);

      // Set external user ID (Supabase user ID)
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await setUserId(userId);
      }

      // Listen to auth changes to update OneSignal user ID
      _supabase.auth.onAuthStateChange.listen((data) {
        final user = data.session?.user;
        if (user != null) {
          setUserId(user.id);
        } else {
          OneSignal.logout();
        }
      });

      _initialized = true;
      debugPrint('Push Notification Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Push Notification Service: $e');
      rethrow;
    }
  }

  /// Set user ID for targeted notifications
  Future<void> setUserId(String userId) async {
    try {
      await OneSignal.login(userId);
      debugPrint('OneSignal user ID set: $userId');
    } catch (e) {
      debugPrint('Error setting OneSignal user ID: $e');
    }
  }

  /// Handle notification opened
  void _handleNotificationOpened(OSNotificationClickEvent event) {
    debugPrint('Notification opened: ${event.notification.additionalData}');
    
    final data = event.notification.additionalData;
    if (data == null) return;

    // Navigate based on notification type
    final type = data['type'] as String?;
    final targetId = data['target_id'] as String?;

    // TODO: Implement navigation logic
    // Example:
    // if (type == 'order_update' && targetId != null) {
    //   navigatorKey.currentState?.pushNamed('/orders/$targetId');
    // } else if (type == 'product' && targetId != null) {
    //   navigatorKey.currentState?.pushNamed('/products/$targetId');
    // }
  }

  /// Handle notification received in foreground
  void _handleNotificationReceived(OSNotificationWillDisplayEvent event) {
    debugPrint('Notification received: ${event.notification.title}');
    
    // Save notification to Supabase database
    _saveNotificationToDatabase(event.notification);

    // Display the notification (can customize or skip)
    event.notification.display();
  }

  /// Save notification to Supabase database
  Future<void> _saveNotificationToDatabase(OSNotification notification) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = notification.additionalData ?? {};
      
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': notification.title ?? '',
        'body': notification.body ?? '',
        'type': data['type'] ?? 'custom',
        'product_id': data['product_id'],
        'order_id': data['order_id'],
        'data': data,
        'is_read': false,
      });

      debugPrint('Notification saved to database');
    } catch (e) {
      debugPrint('Error saving notification to database: $e');
    }
  }

  /// Add tag for user segmentation
  Future<void> addTag(String key, String value) async {
    try {
      await OneSignal.User.addTagWithKey(key, value);
      debugPrint('Tag added: $key = $value');
    } catch (e) {
      debugPrint('Error adding tag: $e');
    }
  }

  /// Remove tag
  Future<void> removeTag(String key) async {
    try {
      await OneSignal.User.removeTag(key);
      debugPrint('Tag removed: $key');
    } catch (e) {
      debugPrint('Error removing tag: $e');
    }
  }

  /// Get notification permission status
  Future<bool> getPermissionStatus() async {
    try {
      return OneSignal.Notifications.permission;
    } catch (e) {
      debugPrint('Error getting permission status: $e');
      return false;
    }
  }

  /// Request permission (can be called manually if needed)
  Future<bool> requestPermission() async {
    try {
      return await OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  /// Enable/disable push notifications
  Future<void> setPushEnabled(bool enabled) async {
    try {
      await OneSignal.Notifications.requestPermission(enabled);
      debugPrint('Push notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Error setting push enabled: $e');
    }
  }

  /// Get OneSignal player/subscription ID
  String? get playerId => OneSignal.User.pushSubscription.id;

  /// Get push subscription token
  String? get pushToken => OneSignal.User.pushSubscription.token;

  /// Logout (clear user association)
  Future<void> logout() async {
    try {
      await OneSignal.logout();
      debugPrint('OneSignal logged out');
    } catch (e) {
      debugPrint('Error logging out from OneSignal: $e');
    }
  }
}
