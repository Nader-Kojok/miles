import 'package:flutter_test/flutter_test.dart';
import 'package:bolide/services/analytics_service.dart';

/// Unit tests for Analytics Service
/// Following Flutter 2025 testing best practices
void main() {
  group('AnalyticsFacade', () {
    late AnalyticsFacade analytics;
    late TestAnalyticsClient testClient;

    setUp(() {
      testClient = TestAnalyticsClient();
      analytics = AnalyticsFacade([testClient]);
    });

    test('trackScreenView logs correct event', () async {
      await analytics.trackScreenView('HomeScreen');

      expect(testClient.events.length, 1);
      expect(testClient.events.first['name'], 'screen_view');
      expect(testClient.events.first['parameters']?['screen_name'], 'HomeScreen');
    });

    test('trackProductView logs correct event', () async {
      await analytics.trackProductView('prod_123', 'Test Product');

      expect(testClient.events.length, 1);
      expect(testClient.events.first['name'], 'product_view');
      expect(testClient.events.first['parameters']?['product_id'], 'prod_123');
      expect(testClient.events.first['parameters']?['product_name'], 'Test Product');
    });

    test('trackAddToCart logs correct event with parameters', () async {
      await analytics.trackAddToCart('prod_123', 'Test Product', 25.99, 2);

      expect(testClient.events.length, 1);
      expect(testClient.events.first['name'], 'add_to_cart');
      expect(testClient.events.first['parameters']?['product_id'], 'prod_123');
      expect(testClient.events.first['parameters']?['price'], 25.99);
      expect(testClient.events.first['parameters']?['quantity'], 2);
      expect(testClient.events.first['parameters']?['currency'], 'XOF');
    });

    test('trackSearch logs correct event', () async {
      await analytics.trackSearch('test query', 10);

      expect(testClient.events.length, 1);
      expect(testClient.events.first['name'], 'search');
      expect(testClient.events.first['parameters']?['search_term'], 'test query');
      expect(testClient.events.first['parameters']?['result_count'], 10);
    });

    test('trackOrderCompleted logs purchase event', () async {
      await analytics.trackOrderCompleted('order_123', 150.50, 3);

      expect(testClient.events.length, 1);
      expect(testClient.events.first['name'], 'purchase');
      expect(testClient.events.first['parameters']?['transaction_id'], 'order_123');
      expect(testClient.events.first['parameters']?['value'], 150.50);
      expect(testClient.events.first['parameters']?['item_count'], 3);
    });

    test('setUserId propagates to all clients', () async {
      await analytics.setUserId('user_123');

      expect(testClient.userId, 'user_123');
    });

    test('setUserProperty propagates to all clients', () async {
      await analytics.setUserProperty('subscription', 'premium');

      expect(testClient.properties['subscription'], 'premium');
    });

    test('supports multiple clients', () async {
      final client1 = TestAnalyticsClient();
      final client2 = TestAnalyticsClient();
      final multiAnalytics = AnalyticsFacade([client1, client2]);

      await multiAnalytics.trackScreenView('TestScreen');

      expect(client1.events.length, 1);
      expect(client2.events.length, 1);
    });
  });
}

/// Test implementation of AnalyticsClient for testing
class TestAnalyticsClient implements AnalyticsClient {
  final List<Map<String, dynamic>> events = [];
  String? userId;
  final Map<String, String?> properties = {};

  @override
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    events.add({
      'name': name,
      'parameters': parameters,
    });
  }

  @override
  Future<void> setUserId(String? userId) async {
    this.userId = userId;
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    properties[name] = value;
  }
}
