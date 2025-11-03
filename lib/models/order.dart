import 'address.dart';

enum OrderStatus { pending, confirmed, processing, shipped, delivered, cancelled }

enum PaymentStatus { pending, paid, failed, refunded }

class OrderItem {
  final String id;
  final String orderId;
  final String? productId;
  final String productName;
  final String? productImage;
  final String? productSku;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    this.productImage,
    this.productSku,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String?,
      productSku: json['product_sku'] as String?,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      totalPrice: (json['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'product_sku': productSku,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String? userId;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double discount;
  final double total;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentMethod;
  final Address shippingAddress;
  final String? customerNotes;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.orderNumber,
    this.userId,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.discount,
    required this.total,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    required this.shippingAddress,
    this.customerNotes,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      userId: json['user_id'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingCost: (json['shipping_cost'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: _parseOrderStatus(json['status'] as String),
      paymentStatus: _parsePaymentStatus(json['payment_status'] as String),
      paymentMethod: json['payment_method'] as String?,
      shippingAddress: Address.fromJson(json['shipping_address'] as Map<String, dynamic>),
      customerNotes: json['customer_notes'] as String?,
      adminNotes: json['admin_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      confirmedAt: json['confirmed_at'] != null ? DateTime.parse(json['confirmed_at'] as String) : null,
      shippedAt: json['shipped_at'] != null ? DateTime.parse(json['shipped_at'] as String) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at'] as String) : null,
      items: json['items'] != null 
        ? (json['items'] as List).map((item) => OrderItem.fromJson(item as Map<String, dynamic>)).toList()
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'tax': tax,
      'discount': discount,
      'total': total,
      'status': status.name,
      'payment_status': paymentStatus.name,
      'payment_method': paymentMethod,
      'shipping_address': shippingAddress.toJson(),
      'customer_notes': customerNotes,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }

  static OrderStatus _parseOrderStatus(String status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(String status) {
    switch (status) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }
}
