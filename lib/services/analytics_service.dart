import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract analytics client interface for type-safe analytics
/// Following 2025 best practices from Andrea Bizzotto
abstract class AnalyticsClient {
  Future<void> logEvent(String name, Map<String, dynamic>? parameters);
  Future<void> setUserId(String? userId);
  Future<void> setUserProperty(String name, String? value);
}

/// Supabase Analytics implementation
/// Stores analytics events in Supabase database
class SupabaseAnalyticsClient implements AnalyticsClient {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      await _supabase.from('analytics_events').insert({
        'event_name': name,
        'event_params': parameters ?? {},
        'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': defaultTargetPlatform.name,
      });
    } catch (e) {
      developer.log('Failed to log Supabase event: $e', name: 'Analytics');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    // User ID is automatically tracked via Supabase auth
    developer.log('Set User ID: $userId', name: 'Analytics');
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      await _supabase.from('analytics_user_properties').upsert({
        'user_id': userId,
        'property_name': name,
        'property_value': value,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      developer.log('Failed to set user property: $e', name: 'Analytics');
    }
  }
}

/// Logger analytics client for development/debugging
class LoggerAnalyticsClient implements AnalyticsClient {
  @override
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    developer.log(
      'Analytics Event: $name',
      name: 'Analytics',
      error: parameters,
    );
  }

  @override
  Future<void> setUserId(String? userId) async {
    developer.log('Set User ID: $userId', name: 'Analytics');
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    developer.log('Set User Property: $name = $value', name: 'Analytics');
  }
}

/// Analytics facade that supports multiple clients
class AnalyticsFacade {
  final List<AnalyticsClient> _clients;

  AnalyticsFacade(this._clients);

  /// Track screen view
  Future<void> trackScreenView(String screenName) async {
    await _logToAll('screen_view', {
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track product view
  Future<void> trackProductView(String productId, String productName) async {
    await _logToAll('product_view', {
      'product_id': productId,
      'product_name': productName,
    });
  }

  /// Track add to cart
  Future<void> trackAddToCart(
    String productId,
    String productName,
    double price,
    int quantity,
  ) async {
    await _logToAll('add_to_cart', {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'currency': 'XOF',
    });
  }

  /// Track remove from cart
  Future<void> trackRemoveFromCart(String productId) async {
    await _logToAll('remove_from_cart', {
      'product_id': productId,
    });
  }

  /// Track search
  Future<void> trackSearch(String query, int resultCount) async {
    await _logToAll('search', {
      'search_term': query,
      'result_count': resultCount,
    });
  }

  /// Track category view
  Future<void> trackCategoryView(String categoryId, String categoryName) async {
    await _logToAll('category_view', {
      'category_id': categoryId,
      'category_name': categoryName,
    });
  }

  /// Track checkout started
  Future<void> trackCheckoutStarted(double totalAmount, int itemCount) async {
    await _logToAll('begin_checkout', {
      'value': totalAmount,
      'item_count': itemCount,
      'currency': 'XOF',
    });
  }

  /// Track order completed
  Future<void> trackOrderCompleted(
    String orderId,
    double totalAmount,
    int itemCount,
  ) async {
    await _logToAll('purchase', {
      'transaction_id': orderId,
      'value': totalAmount,
      'item_count': itemCount,
      'currency': 'XOF',
    });
  }

  /// Track user sign up
  Future<void> trackSignUp(String method) async {
    await _logToAll('sign_up', {
      'method': method, // 'email', 'google', 'phone'
    });
  }

  /// Track user login
  Future<void> trackLogin(String method) async {
    await _logToAll('login', {
      'method': method,
    });
  }

  /// Track favorite added
  Future<void> trackFavoriteAdded(String productId) async {
    await _logToAll('favorite_added', {
      'product_id': productId,
    });
  }

  /// Track favorite removed
  Future<void> trackFavoriteRemoved(String productId) async {
    await _logToAll('favorite_removed', {
      'product_id': productId,
    });
  }

  /// Track app error
  Future<void> trackError(String errorType, String errorMessage) async {
    await _logToAll('app_error', {
      'error_type': errorType,
      'error_message': errorMessage,
    });
  }

  /// Set user ID across all clients
  Future<void> setUserId(String? userId) async {
    for (final client in _clients) {
      await client.setUserId(userId);
    }
  }

  /// Set user property across all clients
  Future<void> setUserProperty(String name, String? value) async {
    for (final client in _clients) {
      await client.setUserProperty(name, value);
    }
  }

  /// Helper to log to all clients
  Future<void> _logToAll(String name, Map<String, dynamic>? parameters) async {
    for (final client in _clients) {
      await client.logEvent(name, parameters);
    }
  }
}

/// Global analytics instance
class Analytics {
  static AnalyticsFacade? _instance;

  static AnalyticsFacade get instance {
    if (_instance == null) {
      throw Exception('Analytics not initialized. Call Analytics.initialize() first.');
    }
    return _instance!;
  }

  /// Initialize analytics with appropriate clients
  static void initialize({bool enableSupabaseTracking = true}) {
    final clients = <AnalyticsClient>[];

    // Always add logger in debug mode
    if (kDebugMode) {
      clients.add(LoggerAnalyticsClient());
    }

    // Add Supabase Analytics in release mode or when explicitly enabled
    if (enableSupabaseTracking && (kReleaseMode || const bool.fromEnvironment('USE_SUPABASE_ANALYTICS'))) {
      clients.add(SupabaseAnalyticsClient());
    }

    _instance = AnalyticsFacade(clients);
    developer.log('Analytics initialized with ${clients.length} client(s)', name: 'Analytics');
  }
}
