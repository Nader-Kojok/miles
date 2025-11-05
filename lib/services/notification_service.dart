import 'package:flutter/foundation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart';

class NotificationService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  // Récupérer toutes les notifications de l'utilisateur
  Future<List<Notification>> getNotifications({
    bool? unreadOnly,
    NotificationType? type,
    int? limit,
  }) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour accéder à vos notifications');
    }

    try {
      var query = _client
          .from('notifications')
          .select()
          .eq('user_id', _userId!);

      if (unreadOnly == true) {
        query = query.eq('is_read', false);
      }

      if (type != null) {
        query = query.eq('type', type.name);
      }

      final orderedQuery = query.order('created_at', ascending: false);

      final limitedQuery = limit != null 
          ? orderedQuery.limit(limit)
          : orderedQuery;

      final response = await limitedQuery;
      return (response as List)
          .map((json) => Notification.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notifications: $e');
    }
  }

  // Récupérer une notification par ID
  Future<Notification?> getNotificationById(String notificationId) async {
    if (_userId == null) {
      return null;
    }

    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('id', notificationId)
          .eq('user_id', _userId!)
          .single();

      return Notification.fromJson(response);
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la notification: $e');
      return null;
    }
  }

  // Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour gérer vos notifications');
    }

    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', _userId!);
    } catch (e) {
      throw Exception('Erreur lors du marquage de la notification: $e');
    }
  }

  // Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour gérer vos notifications');
    }

    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', _userId!)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Erreur lors du marquage des notifications: $e');
    }
  }

  // Compter les notifications non lues
  Future<int> getUnreadCount() async {
    if (_userId == null) {
      return 0;
    }

    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', _userId!)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      debugPrint('Erreur lors du comptage des notifications non lues: $e');
      return 0;
    }
  }

  // Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour gérer vos notifications');
    }

    try {
      await _client
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', _userId!);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la notification: $e');
    }
  }

  // Supprimer toutes les notifications lues
  Future<void> deleteAllRead() async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour gérer vos notifications');
    }

    try {
      await _client
          .from('notifications')
          .delete()
          .eq('user_id', _userId!)
          .eq('is_read', true);
    } catch (e) {
      throw Exception('Erreur lors de la suppression des notifications: $e');
    }
  }

  // Stream des notifications en temps réel
  Stream<List<Notification>> watchNotifications() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .order('created_at', ascending: false)
        .map((data) => 
          data.map((json) => Notification.fromJson(json)).toList()
        );
  }

  // Stream du nombre de notifications non lues en temps réel
  Stream<int> watchUnreadCount() {
    if (_userId == null) {
      return Stream.value(0);
    }

    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .map((data) => data.where((item) => item['is_read'] == false).length);
  }

  // Créer une notification (utilisé par les services ou le backend)
  Future<Notification> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationData = {
        'user_id': userId,
        'type': type.name,
        'title': title,
        'message': message,
        'data': data,
        'is_read': false,
      };

      final response = await _client
          .from('notifications')
          .insert(notificationData)
          .select()
          .single();

      return Notification.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la création de la notification: $e');
    }
  }
}
