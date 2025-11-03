import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _promoCode;
  double _promoDiscount = 0;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  
  double get promoDiscount => _promoDiscount;
  
  double get deliveryFee => subtotal > 0 ? 0 : 0; // Gratuit par défaut
  
  double get total => subtotal - _promoDiscount + deliveryFee;

  void addItem(Product product, {String? season}) {
    final existingIndex = _items.indexWhere((item) => 
      item.product.id == product.id && item.season == season
    );
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product, season: season));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void applyPromoCode(String code) {
    // Logique de validation du code promo
    if (code.toUpperCase() == 'BOLID') {
      _promoCode = code;
      _promoDiscount = subtotal * 0.1; // 10% de réduction
      notifyListeners();
    }
  }

  void removePromoCode() {
    _promoCode = null;
    _promoDiscount = 0;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _promoCode = null;
    _promoDiscount = 0;
    notifyListeners();
  }

  bool hasPromoCode() => _promoCode != null;
  String? get promoCode => _promoCode;
}
