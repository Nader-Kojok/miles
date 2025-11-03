import 'package:flutter/material.dart';

/// Centralized color palette for the Bolide app
/// Based on a black primary theme with consistent accent colors
class AppColors {
  // Primary colors
  static const Color primary = Colors.black;
  static const Color primaryLight = Color(0xFF333333);
  static const Color primaryDark = Color(0xFF000000);
  
  // Background colors
  static const Color background = Colors.white;
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFFE0E0E0);
  
  // Text colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  
  // Status colors (semantic, but aligned with black theme)
  static const Color success = Color(0xFF2E7D32); // Dark green
  static const Color error = Color(0xFFD32F2F); // Dark red
  static const Color warning = Color(0xFFED6C02); // Dark orange
  static const Color info = Color(0xFF0288D1); // Dark blue
  
  // Order status colors (subtle, theme-aligned)
  static const Color statusProcessing = Color(0xFFE65100); // Deep orange
  static const Color statusShipped = Color(0xFF01579B); // Deep blue
  static const Color statusDelivered = Color(0xFF1B5E20); // Deep green
  static const Color statusCancelled = Color(0xFFB71C1C); // Deep red
  
  // UI element colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  static const Color disabled = Color(0xFF9E9E9E);
  
  // Accent colors (minimal use)
  static const Color accent = Color(0xFF424242); // Dark grey
  static const Color accentLight = Color(0xFF757575);
  
  // Notification colors
  static const Color notificationUnread = Color(0xFFF5F5F5); // Very light grey
  static const Color notificationRead = Colors.white;
  
  // Rating/Star color
  static const Color rating = Color(0xFFFFA000); // Amber
  
  // Delete/Destructive action
  static const Color destructive = Color(0xFFC62828); // Deep red
  
  // Helper methods for opacity variations
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Get color for order status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return statusProcessing;
      case 'shipped':
        return statusShipped;
      case 'delivered':
        return statusDelivered;
      case 'cancelled':
        return statusCancelled;
      default:
        return disabled;
    }
  }
  
  // Get color for payment method (if needed)
  static Color getPaymentMethodColor(String methodId) {
    switch (methodId) {
      case 'wave':
        return const Color(0xFF01579B); // Deep blue
      case 'max_it':
      case 'orange_money_app':
      case 'orange_money_ussd':
        return const Color(0xFFE65100); // Deep orange
      case 'carte':
        return primary;
      default:
        return accent;
    }
  }
}
