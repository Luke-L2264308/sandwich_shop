import 'sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

class Cart {
  final Map<Sandwich, int> _items = {};

  // Returns a read-only copy of the items and their quantities
  Map<Sandwich, int> get items => Map.unmodifiable(_items);

  // Helper: find an existing key in the map that is equivalent to the provided sandwich.
  Sandwich? _findMatchingKey(Sandwich sandwich) {
    for (final key in _items.keys) {
      // Consider sandwiches equivalent if their identifying properties match.
      // Adjust properties compared here if Sandwich has additional identity fields.
      if (key.type == sandwich.type &&
          key.isFootlong == sandwich.isFootlong &&
          key.breadType == sandwich.breadType) {
        return key;
      }
    }
    return null;
  }

  void add(Sandwich sandwich, {int quantity = 1}) {
    final Sandwich? matching = _findMatchingKey(sandwich);
    if (matching != null) {
      _items[matching] = _items[matching]! + quantity;
    } else {
      _items[sandwich] = quantity;
    }
  }

  void remove(Sandwich sandwich, {int quantity = 1}) {
    final Sandwich? matching = _findMatchingKey(sandwich);
    if (matching == null) return;
    final currentQty = _items[matching]!;
    if (currentQty > quantity) {
      _items[matching] = currentQty - quantity;
    } else {
      _items.remove(matching);
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
    final Sandwich? matching = _findMatchingKey(sandwich);
    if (matching != null) {
      return _items[matching]!;
    }
    return 0;
  }

  // New: set an exact quantity for a sandwich.
  // - If newQuantity <= 0 the item is removed from the cart.
  // - If the item exists it's updated, otherwise it's added when newQuantity > 0.
  // This is atomic from the caller perspective (single method to set/remove).
  void updateQuantity(Sandwich sandwich, int newQuantity) {
    final Sandwich? matching = _findMatchingKey(sandwich);
    final int q = newQuantity;
    if (matching != null) {
      if (q <= 0) {
        _items.remove(matching);
      } else {
        _items[matching] = q;
      }
    } else {
      if (q > 0) {
        _items[sandwich] = q;
      }
    }
  }

  // Compatibility alias: some code expects updateItemQuantity.
  void updateItemQuantity(Sandwich sandwich, int newQuantity) {
    updateQuantity(sandwich, newQuantity);
  }
}
