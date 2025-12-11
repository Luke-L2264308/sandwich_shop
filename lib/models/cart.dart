import 'sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

class Cart {
  final Map<Sandwich, int> _items = {};

  // Returns a read-only copy of the items and their quantities
  Map<Sandwich, int> get items => Map.unmodifiable(_items);

  void add(Sandwich sandwich, {int quantity = 1}) {
    if (_items.containsKey(sandwich)) {
      _items[sandwich] = _items[sandwich]! + quantity;
    } else {
      _items[sandwich] = quantity;
    }
  }

  void remove(Sandwich sandwich, {int quantity = 1}) {
    if (_items.containsKey(sandwich)) {
      final currentQty = _items[sandwich]!;
      if (currentQty > quantity) {
        _items[sandwich] = currentQty - quantity;
      } else {
        _items.remove(sandwich);
      }
    }
  }

  void clear() {
    _items.clear();
  }

  double get totalPrice {
    final pricingRepository = PricingRepository();
    double total = 0.0;

    for (Sandwich sandwich in _items.keys) {
      int quantity = _items[sandwich]!;
      total += pricingRepository.calculatePrice(
        quantity: quantity,
        isFootlong: sandwich.isFootlong,
      );
    }

    return total;
  }

  bool get isEmpty => _items.isEmpty;

  int get length => _items.length;

  int get countOfItems {
    int total = 0;
    for (Sandwich sandwich in _items.keys) {
      total += _items[sandwich]!;
    }
    return total;
  }

  int getQuantity(Sandwich sandwich) {
    if (_items.containsKey(sandwich)) {
      return _items[sandwich]!;
    }
    return 0;
  }

  // New: set an exact quantity for a sandwich.
  // - If newQuantity <= 0 the item is removed from the cart.
  // - If the item exists it's updated, otherwise it's added when newQuantity > 0.
  // This is atomic from the caller perspective (single method to set/remove).
  void updateQuantity(Sandwich sandwich, int newQuantity) {
    int q = newQuantity;
    if (q <= 0) {
      _items.remove(sandwich);
      return;
    }
    _items[sandwich] = q;
  }

  // Compatibility alias: some code expects updateItemQuantity.
  void updateItemQuantity(Sandwich sandwich, int newQuantity) {
    updateQuantity(sandwich, newQuantity);
  }
}
