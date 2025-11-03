import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/address.dart';
import '../models/cart_item.dart';

class OrderService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  // Créer une nouvelle commande
  Future<Order> createOrder({
    required List<CartItem> items,
    required Address shippingAddress,
    String? promoCode,
    String? paymentMethod,
    String? customerNotes,
  }) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour passer une commande');
    }

    try {
      // Calculer les montants
      final subtotal = items.fold<double>(
        0, 
        (sum, item) => sum + (item.price * item.quantity)
      );
      const shippingCost = 2000.0; // FCFA
      const tax = 0.0;
      double discount = 0;

      // TODO: Appliquer le code promo si fourni
      
      final total = subtotal + shippingCost + tax - discount;

      // Générer le numéro de commande
      final orderNumberResult = await _client.rpc('generate_order_number');
      final orderNumber = orderNumberResult as String;

      // Créer la commande
      final orderData = {
        'order_number': orderNumber,
        'user_id': _userId,
        'subtotal': subtotal,
        'shipping_cost': shippingCost,
        'tax': tax,
        'discount': discount,
        'total': total,
        'status': 'pending',
        'payment_status': 'pending',
        'payment_method': paymentMethod,
        'shipping_address': shippingAddress.toJson(),
        'customer_notes': customerNotes,
      };

      final orderResponse = await _client
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      final orderId = orderResponse['id'] as String;

      // Créer les articles de commande
      final orderItems = items.map((item) => {
        'order_id': orderId,
        'product_id': item.productId,
        'product_name': item.name,
        'product_image': item.imageUrl,
        'unit_price': item.price,
        'quantity': item.quantity,
        'total_price': item.price * item.quantity,
      }).toList();

      await _client.from('order_items').insert(orderItems);

      // Récupérer la commande complète avec les articles
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Commande créée mais impossible de la récupérer');
      }
      return order;
    } catch (e) {
      throw Exception('Erreur lors de la création de la commande: $e');
    }
  }

  // Récupérer toutes les commandes de l'utilisateur
  Future<List<Order>> getUserOrders({
    OrderStatus? status,
    int? limit,
  }) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour accéder à vos commandes');
    }

    try {
      var query = _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', _userId!);

      if (status != null) {
        query = query.eq('status', status.name);
      }

      final orderedQuery = query.order('created_at', ascending: false);
      
      final limitedQuery = limit != null
          ? orderedQuery.limit(limit)
          : orderedQuery;

      final response = await limitedQuery;
      
      return (response as List).map((orderJson) {
        // Extraire les items et les ajouter dans le JSON principal
        final items = orderJson['order_items'] as List?;
        orderJson['items'] = items;
        return Order.fromJson(orderJson as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des commandes: $e');
    }
  }

  // Récupérer une commande par ID
  Future<Order?> getOrderById(String orderId) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour accéder à vos commandes');
    }

    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .eq('user_id', _userId!)
          .single();

      // Extraire les items et les ajouter dans le JSON principal
      final orderJson = Map<String, dynamic>.from(response);
      final items = orderJson['order_items'] as List?;
      orderJson['items'] = items;

      return Order.fromJson(orderJson);
    } catch (e) {
      print('Erreur lors de la récupération de la commande: $e');
      return null;
    }
  }

  // Récupérer une commande par numéro
  Future<Order?> getOrderByNumber(String orderNumber) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour accéder à vos commandes');
    }

    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('order_number', orderNumber)
          .eq('user_id', _userId!)
          .single();

      final orderJson = Map<String, dynamic>.from(response);
      final items = orderJson['order_items'] as List?;
      orderJson['items'] = items;

      return Order.fromJson(orderJson);
    } catch (e) {
      print('Erreur lors de la récupération de la commande: $e');
      return null;
    }
  }

  // Annuler une commande
  Future<void> cancelOrder(String orderId) async {
    if (_userId == null) {
      throw Exception('Veuillez vous connecter pour gérer vos commandes');
    }

    try {
      await _client
          .from('orders')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId)
          .eq('user_id', _userId!)
          .inFilter('status', ['pending', 'confirmed']); // Seulement si pending ou confirmed
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de la commande: $e');
    }
  }

  // Compter les commandes par statut
  Future<Map<String, int>> getOrderCountsByStatus() async {
    if (_userId == null) {
      return {};
    }

    try {
      final response = await _client
          .from('orders')
          .select('status')
          .eq('user_id', _userId!);

      final orders = response as List;
      final counts = <String, int>{};

      for (final order in orders) {
        final status = order['status'] as String;
        counts[status] = (counts[status] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('Erreur lors du comptage des commandes: $e');
      return {};
    }
  }

  // Récupérer le total dépensé par l'utilisateur
  Future<double> getTotalSpent() async {
    if (_userId == null) {
      return 0;
    }

    try {
      final response = await _client
          .from('orders')
          .select('total')
          .eq('user_id', _userId!)
          .inFilter('status', ['delivered', 'confirmed', 'shipped']);

      final orders = response as List;
      return orders.fold<double>(
        0, 
        (sum, order) => sum + (order['total'] as num).toDouble()
      );
    } catch (e) {
      print('Erreur lors du calcul du total dépensé: $e');
      return 0;
    }
  }

  // Stream des commandes en temps réel
  Stream<List<Order>> watchUserOrders() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .order('created_at', ascending: false)
        .map((data) => 
          data.map((orderJson) => Order.fromJson(orderJson)).toList()
        );
  }
}
