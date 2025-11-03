import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notification.dart' as app_notification;
import '../utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();
  
  List<app_notification.Notification> _allNotifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await _notificationService.getNotifications();
      setState(() {
        _allNotifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<app_notification.Notification> _getFilteredNotifications() {
    final index = _tabController.index;
    if (index == 0) return _allNotifications; // Tout
    
    app_notification.NotificationType? filterType;
    switch (index) {
      case 1:
        filterType = app_notification.NotificationType.order;
        break;
      case 2:
        filterType = app_notification.NotificationType.promo;
        break;
      case 3:
        filterType = app_notification.NotificationType.system;
        break;
    }
    
    return _allNotifications.where((n) => n.type == filterType).toList();
  }

  Map<String, List<app_notification.Notification>> _groupNotificationsByDate(List<app_notification.Notification> notifications) {
    final Map<String, List<app_notification.Notification>> grouped = {};
    final now = DateTime.now();
    
    for (var notification in notifications) {
      String dateKey;
      final difference = now.difference(notification.createdAt).inDays;
      
      if (difference == 0) {
        dateKey = 'Aujourd\'hui';
      } else if (difference == 1) {
        dateKey = 'Hier';
      } else {
        dateKey = '${notification.createdAt.day} ${_getMonthName(notification.createdAt.month)} ${notification.createdAt.year}';
      }
      
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(notification);
    }
    
    return grouped;
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return months[month - 1];
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Toutes les notifications sont marquées comme lues'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(app_notification.Notification notification) async {
    try {
      await _notificationService.deleteNotification(notification.id);
      setState(() {
        _allNotifications.removeWhere((n) => n.id == notification.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification supprimée'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Erreur: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadNotifications,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.black),
            tooltip: 'Tout marquer comme lu',
            onPressed: _markAllAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            tooltip: 'Paramètres',
            onPressed: () {
              // Navigate to notification settings
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'Tout'),
            Tab(text: 'Commandes'),
            Tab(text: 'Promotions'),
            Tab(text: 'Système'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(4, (index) => _buildNotificationList()),
      ),
    );
  }

  Widget _buildNotificationList() {
    final notifications = _getFilteredNotifications();
    
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }
    
    final groupedNotifications = _groupNotificationsByDate(notifications);
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groupedNotifications.length,
      itemBuilder: (context, index) {
        final dateKey = groupedNotifications.keys.elementAt(index);
        final items = groupedNotifications[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                dateKey,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ...items.map((notification) => _buildNotificationCard(notification)),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard(app_notification.Notification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.destructive,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteNotification(notification),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.notificationRead : AppColors.notificationUnread,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            backgroundColor: _getNotificationColor(notification.type).withOpacity(0.1),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
              size: 24,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              fontSize: 15,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(notification.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'read',
                child: Row(
                  children: [
                    Icon(
                      notification.isRead ? Icons.mark_email_unread : Icons.mark_email_read,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(notification.isRead ? 'Marquer non lu' : 'Marquer comme lu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'read') {
                try {
                  await _notificationService.markAsRead(notification.id);
                  await _loadNotifications();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              } else if (value == 'delete') {
                _deleteNotification(notification);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous serez informé ici de vos commandes',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  IconData _getNotificationIcon(app_notification.NotificationType type) {
    switch (type) {
      case app_notification.NotificationType.order:
        return Icons.shopping_bag;
      case app_notification.NotificationType.promo:
        return Icons.local_offer;
      case app_notification.NotificationType.system:
        return Icons.info;
      case app_notification.NotificationType.product:
        return Icons.inventory;
    }
  }

  Color _getNotificationColor(app_notification.NotificationType type) {
    switch (type) {
      case app_notification.NotificationType.order:
        return Colors.blue;
      case app_notification.NotificationType.promo:
        return Colors.orange;
      case app_notification.NotificationType.system:
        return Colors.grey;
      case app_notification.NotificationType.product:
        return Colors.green;
    }
  }
}
