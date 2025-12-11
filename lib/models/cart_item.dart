import 'package:flutter/foundation.dart';

class CartItemOptions {
  // ...existing code or fields...
  final String breadType;
  final bool isFootlong;
  // add other option fields as needed

  const CartItemOptions({
    required this.breadType,
    required this.isFootlong,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItemOptions &&
        other.breadType == breadType &&
        other.isFootlong == isFootlong;
  }

  @override
  int get hashCode => Object.hash(breadType, isFootlong);
}

class CartItem {
  final String id;
  final String productId;
  final CartItemOptions options;
  final double unitPrice;
  int quantity;
  final int maxQuantity;
  final int stock;

  CartItem({
    required this.id,
    required this.productId,
    required this.options,
    required this.unitPrice,
    required this.quantity,
    required this.maxQuantity,
    required this.stock,
  });

  double get subtotal => unitPrice * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    CartItemOptions? options,
    double? unitPrice,
    int? quantity,
    int? maxQuantity,
    int? stock,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      options: options ?? this.options,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      stock: stock ?? this.stock,
    );
  }
}
