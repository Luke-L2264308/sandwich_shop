import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class PersistenceException implements Exception {
  final String message;
  PersistenceException(this.message);
}

class CartProvider with ChangeNotifier {
  // simple in-memory map of cart items keyed by id
  final Map<String, CartItem> _items = {};

  String? lastError;

  // expose unmodifiable view
  List<CartItem> get items => _items.values.toList(growable: false);

  double get total =>
      _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  // helper: add or replace item (used to seed provider)
  void setItems(List<CartItem> items) {
    _items.clear();
    for (final it in items) {
      _items[it.id] = it;
    }
    notifyListeners();
  }

  // Optimistic update: update quantity immediately, attempt persistence,
  // rollback if persistence fails.
  Future<void> updateItemQuantity(String cartItemId, int quantity) async {
    final existing = _items[cartItemId];
    if (existing == null) {
      throw ArgumentError('Cart item not found: $cartItemId');
    }

    final int clamped = quantity.clamp(0, existing.maxQuantity).toInt();
    final CartItem previous = existing.copyWith();
    // apply optimistic update
    if (clamped == 0) {
      _items.remove(cartItemId);
    } else {
      _items[cartItemId] = existing.copyWith(quantity: clamped);
    }
    notifyListeners();

    try {
      await _persistUpdate(cartItemId, clamped);
      lastError = null;
    } catch (e) {
      // rollback on failure
      _items[previous.id] = previous;
      lastError = e is PersistenceException ? e.message : 'Failed to update';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _persistUpdate(String cartItemId, int quantity) async {
    // Simulated network/local persistence with delay.
    // Replace this with real persistence integration.
    await Future.delayed(const Duration(milliseconds: 250));
    // For now succeed. To simulate failure in tests, throw PersistenceException.
    // Example failure simulation (commented):
    // if (quantity > 999) throw PersistenceException('Simulated failure');
  }

  // small helper methods used by UI or tests
  CartItem? getById(String id) => _items[id];

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
