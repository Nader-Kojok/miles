import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final String? description;
  final String? imageUrl;
  final String? parentId;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  
  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.description,
    this.imageUrl,
    this.parentId,
    this.displayOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      parentId: json['parent_id'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'description': description,
      'image_url': imageUrl,
      'parent_id': parentId,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  IconData get iconData {
    // Convertir le nom de l'icône Material en IconData
    switch (icon) {
      case 'build':
        return Icons.build;
      case 'speed':
        return Icons.speed;
      case 'settings':
        return Icons.settings;
      case 'flash_on':
        return Icons.flash_on;
      case 'directions_car':
        return Icons.directions_car;
      case 'filter_list':
        return Icons.filter_list;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'ac_unit':
        return Icons.ac_unit;
      default:
        return Icons.category;
    }
  }
}
