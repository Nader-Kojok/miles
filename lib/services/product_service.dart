import 'package:flutter/foundation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/category.dart' as models;

class ProductService {
  final SupabaseClient _client = Supabase.instance.client;

  // Récupérer tous les produits actifs
  Future<List<Product>> getProducts({
    String? categoryId,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client
          .from('products')
          .select()
          .eq('is_active', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final orderedQuery = query.order('created_at', ascending: false);

      var finalQuery = orderedQuery;
      
      if (limit != null) {
        finalQuery = orderedQuery.limit(limit);
      }

      if (offset != null) {
        finalQuery = finalQuery.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await finalQuery;
      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des produits: $e');
    }
  }

  // Récupérer un produit par ID
  Future<Product?> getProductById(String id) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', id)
          .eq('is_active', true)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      debugPrint('Erreur lors de la récupération du produit: $e');
      return null;
    }
  }

  // Récupérer un produit par slug
  Future<Product?> getProductBySlug(String slug) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('slug', slug)
          .eq('is_active', true)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      debugPrint('Erreur lors de la récupération du produit: $e');
      return null;
    }
  }

  // Rechercher des produits (simple query)
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('is_active', true)
          .or('name.ilike.%$query%,description.ilike.%$query%,brand.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche de produits: $e');
    }
  }

  // Recherche avancée avec critères multiples
  Future<List<Product>> advancedSearch({
    String? query,
    String? sku,
    String? brand,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    String? sortBy,
  }) async {
    try {
      var queryBuilder = _client
          .from('products')
          .select()
          .eq('is_active', true);

      // Apply text search (name, description, or tags)
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'name.ilike.%$query%,description.ilike.%$query%,brand.ilike.%$query%'
        );
      }

      // Search by SKU
      if (sku != null && sku.isNotEmpty) {
        queryBuilder = queryBuilder.ilike('sku', '%$sku%');
      }

      // Filter by brand
      if (brand != null && brand.isNotEmpty) {
        queryBuilder = queryBuilder.eq('brand', brand);
      }

      // Filter by category
      if (categoryId != null && categoryId.isNotEmpty) {
        queryBuilder = queryBuilder.eq('category_id', categoryId);
      }

      // Filter by price range
      if (minPrice != null) {
        queryBuilder = queryBuilder.gte('price', minPrice);
      }
      if (maxPrice != null) {
        queryBuilder = queryBuilder.lte('price', maxPrice);
      }

      // Filter by stock
      if (inStockOnly == true) {
        queryBuilder = queryBuilder.eq('in_stock', true);
      }

      // Apply sorting (after all filters)
      final orderedQuery = switch (sortBy) {
        'price_asc' => queryBuilder.order('price', ascending: true),
        'price_desc' => queryBuilder.order('price', ascending: false),
        'name_asc' => queryBuilder.order('name', ascending: true),
        'name_desc' => queryBuilder.order('name', ascending: false),
        'newest' => queryBuilder.order('created_at', ascending: false),
        _ => queryBuilder.order('created_at', ascending: false),
      };

      final response = await orderedQuery;

      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche avancée: $e');
    }
  }

  // Rechercher par SKU spécifique
  Future<Product?> searchBySku(String sku) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('sku', sku)
          .maybeSingle();

      if (response == null) return null;
      return Product.fromJson(response);
    } catch (e) {
      debugPrint('Erreur lors de la recherche par SKU: $e');
      return null;
    }
  }

  // Récupérer les produits en vedette
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('is_featured', true)
          .limit(limit)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des produits vedette: $e');
    }
  }

  // Récupérer les produits par catégorie
  Future<List<Product>> getProductsByCategory(String categoryId, {int? limit}) async {
    try {
      var query = _client
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des produits par catégorie: $e');
    }
  }

  // Récupérer les produits en promotion
  Future<List<Product>> getProductsOnSale({int? limit}) async {
    try {
      var query = _client
          .from('products')
          .select()
          .eq('is_active', true)
          .not('compare_at_price', 'is', null)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      final products = (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filtrer pour ne garder que ceux avec un vrai discount
      return products.where((p) => p.isOnSale).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des produits en promotion: $e');
    }
  }

  // Récupérer toutes les catégories actives
  Future<List<models.Category>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return (response as List)
          .map((json) => models.Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des catégories: $e');
    }
  }

  // Récupérer une catégorie par ID
  Future<models.Category?> getCategoryById(String id) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('id', id)
          .eq('is_active', true)
          .single();

      return models.Category.fromJson(response);
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la catégorie: $e');
      return null;
    }
  }

  // Récupérer une catégorie par slug
  Future<models.Category?> getCategoryBySlug(String slug) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('slug', slug)
          .eq('is_active', true)
          .single();

      return models.Category.fromJson(response);
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la catégorie: $e');
      return null;
    }
  }

  // Récupérer les produits par marque
  Future<List<Product>> getProductsByBrand(String brand, {int? limit}) async {
    try {
      var query = _client
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('brand', brand)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des produits par marque: $e');
    }
  }

  // Compter le nombre de produits par catégorie
  Future<int> countProductsByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('products')
          .select('id')
          .eq('is_active', true)
          .eq('category_id', categoryId);

      return (response as List).length;
    } catch (e) {
      debugPrint('Erreur lors du comptage des produits: $e');
      return 0;
    }
  }
}
