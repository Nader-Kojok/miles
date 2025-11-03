import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

/// Deep Link Service
/// Handles Universal Links (iOS) and App Links (Android)
/// Supports: bolide://... and https://bolide.app/...
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

    // Handle both custom scheme (bolide://) and universal links (https://bolide.app)
    final path = uri.path;
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) {
      return DeepLinkRoute(type: DeepLinkType.home);
    }

    // Product: bolide://product/123 or https://bolide.app/product/123
    if (segments[0] == 'product' || segments[0] == 'products') {
      if (segments.length > 1) {
        return DeepLinkRoute(
          type: DeepLinkType.product,
          id: segments[1],
        );
      }
    }

    // Order: bolide://order/123 or https://bolide.app/order/123
    if (segments[0] == 'order' || segments[0] == 'orders') {
      if (segments.length > 1) {
        return DeepLinkRoute(
          type: DeepLinkType.order,
          id: segments[1],
        );
      }
      return DeepLinkRoute(type: DeepLinkType.orders);
    }

    // Category: bolide://category/brakes or https://bolide.app/category/brakes
    if (segments[0] == 'category' || segments[0] == 'categories') {
      if (segments.length > 1) {
        return DeepLinkRoute(
          type: DeepLinkType.category,
          slug: segments[1],
        );
      }
    }

    // Brand: bolide://brand/bosch or https://bolide.app/brand/bosch
    if (segments[0] == 'brand' || segments[0] == 'brands') {
      if (segments.length > 1) {
        return DeepLinkRoute(
          type: DeepLinkType.brand,
          slug: segments[1],
        );
      }
    }

    // Search: bolide://search?q=brake+pads or https://bolide.app/search?q=brake+pads
    if (segments[0] == 'search') {
      final query = uri.queryParameters['q'] ?? '';
      return DeepLinkRoute(
        type: DeepLinkType.search,
        query: query,
      );
    }

    // Cart: bolide://cart or https://bolide.app/cart
    if (segments[0] == 'cart') {
      return DeepLinkRoute(type: DeepLinkType.cart);
    }

    // Profile: bolide://profile or https://bolide.app/profile
    if (segments[0] == 'profile' || segments[0] == 'account') {
      return DeepLinkRoute(type: DeepLinkType.profile);
    }

    // Favorites: bolide://favorites or https://bolide.app/favorites
    if (segments[0] == 'favorites' || segments[0] == 'wishlist') {
      return DeepLinkRoute(type: DeepLinkType.favorites);
    }

    // Notification: bolide://notification/123
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
    return 'https://bolide.app/product/$productId';
  }

  /// Generate shareable link for a category
  String generateCategoryLink(String categorySlug) {
    return 'https://bolide.app/category/$categorySlug';
  }

  /// Generate shareable link for search
  String generateSearchLink(String query) {
    final encodedQuery = Uri.encodeComponent(query);
    return 'https://bolide.app/search?q=$encodedQuery';
  }

  /// Generate order tracking link
  String generateOrderLink(String orderId) {
    return 'https://bolide.app/order/$orderId';
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
