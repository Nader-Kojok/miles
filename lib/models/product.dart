class Product {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final double? compareAtPrice;
  final String? categoryId;
  final String? imageUrl;
  final List<String>? images;
  final bool inStock;
  final int stockQuantity;
  final String? sku;
  final String? brand;
  final double? weight;
  final Map<String, dynamic>? dimensions;
  final List<String>? tags;
  final bool isFeatured;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.compareAtPrice,
    this.categoryId,
    this.imageUrl,
    this.images,
    this.inStock = true,
    this.stockQuantity = 0,
    this.sku,
    this.brand,
    this.weight,
    this.dimensions,
    this.tags,
    this.isFeatured = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      compareAtPrice: json['compare_at_price'] != null 
        ? (json['compare_at_price'] as num).toDouble() 
        : null,
      categoryId: json['category_id'] as String?,
      imageUrl: json['image_url'] as String?,
      images: json['images'] != null 
        ? List<String>.from(json['images'] as List) 
        : null,
      inStock: json['in_stock'] as bool? ?? true,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      sku: json['sku'] as String?,
      brand: json['brand'] as String?,
      weight: json['weight'] != null 
        ? (json['weight'] as num).toDouble() 
        : null,
      dimensions: json['dimensions'] as Map<String, dynamic>?,
      tags: json['tags'] != null 
        ? List<String>.from(json['tags'] as List) 
        : null,
      isFeatured: json['is_featured'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'compare_at_price': compareAtPrice,
      'category_id': categoryId,
      'image_url': imageUrl,
      'images': images,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
      'sku': sku,
      'brand': brand,
      'weight': weight,
      'dimensions': dimensions,
      'tags': tags,
      'is_featured': isFeatured,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Calculer le pourcentage de réduction
  double? get discountPercentage {
    if (compareAtPrice != null && compareAtPrice! > price) {
      return ((compareAtPrice! - price) / compareAtPrice!) * 100;
    }
    return null;
  }

  // Vérifier si le produit est en promotion
  bool get isOnSale => compareAtPrice != null && compareAtPrice! > price;

  // Catégorie pour compatibilité avec l'ancien code
  String get category => categoryId ?? '';
}
