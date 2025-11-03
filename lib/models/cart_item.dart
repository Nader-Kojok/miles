import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final String? season; // Pour les pneus
  
  CartItem({
    required this.product,
    this.quantity = 1,
    this.season,
  });

  double get totalPrice => product.price * quantity;

  // Getters pour faciliter l'accès aux propriétés du produit
  String get productId => product.id;
  String get name => product.name;
  String? get imageUrl => product.imageUrl;
  double get price => product.price;
  String? get sku => product.sku;

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'season': season,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] as int,
      season: json['season'] as String?,
    );
  }
}
