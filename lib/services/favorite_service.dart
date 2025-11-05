import 'package:flutter/foundation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class FavoriteService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  // Récupérer tous les favoris de l'utilisateur avec les détails des produits
  Future<List<Product>> getUserFavorites() async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour accéder à vos favoris');
    }

    try {
      final response = await _client
          .from('favorites')
          .select('product_id, products(*)')
          .eq('user_id', _userId!);

      final favorites = response as List;
      return favorites
          .where((fav) => fav['products'] != null)
          .map((fav) => Product.fromJson(fav['products'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des favoris: $e');
    }
  }

  // Récupérer uniquement les IDs des produits favoris
  Future<List<String>> getUserFavoriteIds() async {
    if (_userId == null) {
      return [];
    }

    try {
      final response = await _client
          .from('favorites')
          .select('product_id')
          .eq('user_id', _userId!);

      return (response as List)
          .map((fav) => fav['product_id'] as String)
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des IDs favoris: $e');
      return [];
    }
  }

  // Ajouter un produit aux favoris
  Future<void> addToFavorites(String productId) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour ajouter aux favoris');
    }

    try {
      await _client.from('favorites').insert({
        'user_id': _userId,
        'product_id': productId,
      });
    } catch (e) {
      // Si le favori existe déjà, on ignore l'erreur (contrainte unique)
      if (!e.toString().contains('duplicate') && !e.toString().contains('unique')) {
        throw Exception('Erreur lors de l\'ajout aux favoris: $e');
      }
    }
  }

  // Retirer un produit des favoris
  Future<void> removeFromFavorites(String productId) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour gérer vos favoris');
    }

    try {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', _userId!)
          .eq('product_id', productId);
    } catch (e) {
      throw Exception('Erreur lors du retrait des favoris: $e');
    }
  }

  // Vérifier si un produit est en favori
  Future<bool> isFavorite(String productId) async {
    if (_userId == null) {
      return false;
    }

    try {
      final response = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', _userId!)
          .eq('product_id', productId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Erreur lors de la vérification du favori: $e');
      return false;
    }
  }

  // Toggle favori (ajouter si pas présent, retirer si présent)
  Future<bool> toggleFavorite(String productId) async {
    final isCurrentlyFavorite = await isFavorite(productId);

    if (isCurrentlyFavorite) {
      await removeFromFavorites(productId);
      return false;
    } else {
      await addToFavorites(productId);
      return true;
    }
  }

  // Compter le nombre de favoris
  Future<int> getFavoritesCount() async {
    if (_userId == null) {
      return 0;
    }

    try {
      final response = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', _userId!);

      return (response as List).length;
    } catch (e) {
      debugPrint('Erreur lors du comptage des favoris: $e');
      return 0;
    }
  }

  // Supprimer tous les favoris de l'utilisateur
  Future<void> clearAllFavorites() async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour gérer vos favoris');
    }

    try {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', _userId!);
    } catch (e) {
      throw Exception('Erreur lors de la suppression des favoris: $e');
    }
  }
}
