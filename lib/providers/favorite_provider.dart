import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/favorite_service.dart';
import '../utils/error_handler.dart';

/// Favorites Provider for global state management
/// Following 2025 best practices with optimistic updates
class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();

  List<Product> _favorites = [];
  Set<String> _favoriteIds = {};
  
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get favorites => _favorites;
  Set<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _favorites.length;
  bool get hasFavorites => _favorites.isNotEmpty;

  /// Check if product is favorite
  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  /// Load all favorites
  Future<void> loadFavorites() async {
    try {
      _setLoading(true);
      _error = null;

      _favorites = await GlobalErrorHandler.retryOperation(
        operation: () => _favoriteService.getUserFavorites(),
        maxAttempts: 2,
      );

      _favoriteIds = _favorites.map((p) => p.id).toSet();

      notifyListeners();
    } catch (e) {
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error loading favorites: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Load only favorite IDs (lightweight)
  Future<void> loadFavoriteIds() async {
    try {
      final ids = await _favoriteService.getUserFavoriteIds();
      _favoriteIds = ids.toSet();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorite IDs: $e');
    }
  }

  /// Toggle favorite with optimistic update
  Future<bool> toggleFavorite(Product product) async {
    final productId = product.id;
    final wasAlreadyFavorite = _favoriteIds.contains(productId);

    // Optimistic update
    if (wasAlreadyFavorite) {
      _favoriteIds.remove(productId);
      _favorites.removeWhere((p) => p.id == productId);
    } else {
      _favoriteIds.add(productId);
      _favorites.insert(0, product);
    }
    notifyListeners();

    try {
      // Perform actual operation
      final isNowFavorite = await _favoriteService.toggleFavorite(productId);
      
      return isNowFavorite;
    } catch (e) {
      // Rollback on error
      if (wasAlreadyFavorite) {
        _favoriteIds.add(productId);
        _favorites.insert(0, product);
      } else {
        _favoriteIds.remove(productId);
        _favorites.removeWhere((p) => p.id == productId);
      }
      
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error toggling favorite: $e');
      notifyListeners();
      
      rethrow;
    }
  }

  /// Add to favorites
  Future<void> addToFavorites(Product product) async {
    final productId = product.id;
    
    // Optimistic update
    if (!_favoriteIds.contains(productId)) {
      _favoriteIds.add(productId);
      _favorites.insert(0, product);
      notifyListeners();
    }

    try {
      await _favoriteService.addToFavorites(productId);
    } catch (e) {
      // Rollback on error
      _favoriteIds.remove(productId);
      _favorites.removeWhere((p) => p.id == productId);
      
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error adding to favorites: $e');
      notifyListeners();
      
      rethrow;
    }
  }

  /// Remove from favorites
  Future<void> removeFromFavorites(String productId) async {
    // Find and store the product for potential rollback
    final product = _favorites.firstWhere(
      (p) => p.id == productId,
      orElse: () => null as Product,
    );
    final index = _favorites.indexWhere((p) => p.id == productId);

    // Optimistic update
    _favoriteIds.remove(productId);
    _favorites.removeWhere((p) => p.id == productId);
    notifyListeners();

    try {
      await _favoriteService.removeFromFavorites(productId);
    } catch (e) {
      // Rollback on error
      _favoriteIds.add(productId);
      if (product != null && index >= 0) {
        _favorites.insert(index, product);
      }
      
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error removing from favorites: $e');
      notifyListeners();
      
      rethrow;
    }
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    // Store for potential rollback
    final previousFavorites = List<Product>.from(_favorites);
    final previousIds = Set<String>.from(_favoriteIds);

    // Optimistic update
    _favorites.clear();
    _favoriteIds.clear();
    notifyListeners();

    try {
      await _favoriteService.clearAllFavorites();
    } catch (e) {
      // Rollback on error
      _favorites = previousFavorites;
      _favoriteIds = previousIds;
      
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error clearing favorites: $e');
      notifyListeners();
      
      rethrow;
    }
  }

  /// Clear local data (on logout)
  void clear() {
    _favorites = [];
    _favoriteIds = {};
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
