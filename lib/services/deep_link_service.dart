import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

/// Deep Link Service
/// Handles Universal Links (iOS) and App Links (Android)
/// Supports: miles://... and https://miles.app/...
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  final _linkController = StreamController<Uri>.broadcast();

  /// Stream of incoming deep links
  Stream<Uri> get linkStream => _linkController.stream;

  /// Initialize deep link handling
  Future<void> initialize() async {
    // Handle initial link (app opened via link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _linkController.add(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // Listen to incoming links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('Received deep link: $uri');
        _linkController.add(uri);
      },
      onError: (err) {
        debugPrint('Error receiving deep link: $err');
      },
    );
  }

  /// Handle deep link navigation
  /// Returns the route to navigate to based on the URI
  DeepLinkRoute? parseDeepLink(Uri uri) {
    debugPrint('Parsing deep link: $uri');

    // Handle both custom scheme (miles://) and universal links (https://miles.app)
    final path = uri.path;
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) {
      return DeepLinkRoute(type: DeepLinkType.home);
    }

    // Product: miles://product/123 or https://miles.app/product/123
    if (segments[0] == 'product' || segments[0] == 'products') {
      if (segments.length > 1) {
        return DeepLinkRoute(
          type: DeepLinkType.product,
          id: segments[1],
        );
      }
    }

    // Order: miles://order/123 or https://miles.app/order/123
    if (segments[0] == 'order' || segments[0] == 'orders') {
      if (segments.length > 1) {
        return DeepLinkRoute(
          type: DeepLinkType.order,
          id: segments[1],
        );
      }
      return DeepLinkRoute(type: DeepLinkType.orders);
    }

    // Category: miles://category/brakes or https://miles.app/category/brakes
    if (segments[0] == 'category' || segments[0] == 'categories') {
      if (segments.length > 1) {
        return DeepLinkRoute(
          type: DeepLinkType.category,
          slug: segments[1],
        );
      }
    }

    // Brand: miles://brand/bosch or https://miles.app/brand/bosch
    if (segments[0] == 'brand' || segments[0] == 'brands') {
      if (segments.length > 1) {
        return DeepLinkRoute(
          type: DeepLinkType.brand,
          slug: segments[1],
        );
      }
    }

    // Search: miles://search?q=brake+pads or https://miles.app/search?q=brake+pads
    if (segments[0] == 'search') {
      final query = uri.queryParameters['q'] ?? '';
      return DeepLinkRoute(
        type: DeepLinkType.search,
        query: query,
      );
    }

    // Cart: miles://cart or https://miles.app/cart
    if (segments[0] == 'cart') {
      return DeepLinkRoute(type: DeepLinkType.cart);
    }

    // Profile: miles://profile or https://miles.app/profile
    if (segments[0] == 'profile' || segments[0] == 'account') {
      return DeepLinkRoute(type: DeepLinkType.profile);
    }

    // Favorites: miles://favorites or https://miles.app/favorites
    if (segments[0] == 'favorites' || segments[0] == 'wishlist') {
      return DeepLinkRoute(type: DeepLinkType.favorites);
    }

    // Notification: miles://notification/123
    if (segments[0] == 'notification' || segments[0] == 'notifications') {
      if (segments.length > 1) {
        return DeepLinkRoute(
          type: DeepLinkType.notification,
          id: segments[1],
        );
      }
    }

    // Unknown link
    return null;
  }

  /// Generate shareable link for a product
  String generateProductLink(String productId) {
    return 'https://miles.app/product/$productId';
  }

  /// Generate shareable link for a category
  String generateCategoryLink(String categorySlug) {
    return 'https://miles.app/category/$categorySlug';
  }

  /// Generate shareable link for search
  String generateSearchLink(String query) {
    final encodedQuery = Uri.encodeComponent(query);
    return 'https://miles.app/search?q=$encodedQuery';
  }

  /// Generate order tracking link
  String generateOrderLink(String orderId) {
    return 'https://miles.app/order/$orderId';
  }

  /// Dispose
  void dispose() {
    _linkSubscription?.cancel();
    _linkController.close();
  }
}

/// Deep link route information
class DeepLinkRoute {
  final DeepLinkType type;
  final String? id;
  final String? slug;
  final String? query;

  DeepLinkRoute({
    required this.type,
    this.id,
    this.slug,
    this.query,
  });

  @override
  String toString() {
    return 'DeepLinkRoute(type: $type, id: $id, slug: $slug, query: $query)';
  }
}

/// Types of deep links
enum DeepLinkType {
  home,
  product,
  category,
  brand,
  search,
  cart,
  profile,
  orders,
  order,
  favorites,
  notification,
}
