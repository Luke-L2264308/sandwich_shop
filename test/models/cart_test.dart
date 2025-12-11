import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

void main() {
  group('Cart', () {
    late Cart cart;
    late Sandwich sandwichA;
    late Sandwich sandwichB;

    setUp(() {
      cart = Cart();
      sandwichA = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: false,
        breadType: BreadType.wheat,
      );
      sandwichB = Sandwich(
        type: SandwichType.chickenTeriyaki,
        isFootlong: true,
        breadType: BreadType.white,
      );
    });

    test('should start empty', () {
      expect(cart.isEmpty, isTrue);
      expect(cart.length, 0);
      expect(cart.items, isEmpty);
    });

    test('should add a sandwich with default quantity 1', () {
      cart.add(sandwichA);
      expect(cart.getQuantity(sandwichA), 1);
      expect(cart.length, 1);
      expect(cart.isEmpty, isFalse);
    });

    test('should add a sandwich with custom quantity', () {
      cart.add(sandwichA, quantity: 3);
      expect(cart.getQuantity(sandwichA), 3);
      expect(cart.length, 1);
    });

    test('should increase quantity if same sandwich is added again', () {
      cart.add(sandwichA);
      cart.add(sandwichA, quantity: 2);
      expect(cart.getQuantity(sandwichA), 3);
    });

    test('should add multiple different sandwiches', () {
      cart.add(sandwichA);
      cart.add(sandwichB, quantity: 2);
      expect(cart.getQuantity(sandwichA), 1);
      expect(cart.getQuantity(sandwichB), 2);
      expect(cart.length, 2);
    });

    test('should remove quantity of a sandwich', () {
      cart.add(sandwichA, quantity: 3);
      cart.remove(sandwichA, quantity: 2);
      expect(cart.getQuantity(sandwichA), 1);
      expect(cart.length, 1);
    });

    test('should remove sandwich completely if quantity drops to zero', () {
      cart.add(sandwichA, quantity: 2);
      cart.remove(sandwichA, quantity: 2);
      expect(cart.getQuantity(sandwichA), 0);
      expect(cart.isEmpty, isTrue);
      expect(cart.length, 0);
    });

    test('should not throw an error when removing a sandwich not in cart', () {
      expect(() => cart.remove(sandwichA), returnsNormally);
    });

    test('should clear all items', () {
      cart.add(sandwichA);
      cart.add(sandwichB);
      cart.clear();
      expect(cart.isEmpty, isTrue);
      expect(cart.items, isEmpty);
    });

    test('getQuantity returns correct quantity', () {
      cart.add(sandwichA, quantity: 4);
      expect(cart.getQuantity(sandwichA), 4);
      expect(cart.getQuantity(sandwichB), 0);
    });

    test('items getter is unmodifiable', () {
      cart.add(sandwichA);
      final Map<Sandwich, int> items = cart.items;
      expect(() => items[sandwichB] = 2, throwsUnsupportedError);
    });

    test('totalPrice calculates sum using PricingRepository', () {
      cart.add(sandwichA, quantity: 2);
      cart.add(sandwichB, quantity: 1);
      expect(cart.totalPrice, isA<double>());
      expect(cart.totalPrice, greaterThan(0));
    });

    test('should handle adding and removing multiple sandwiches correctly', () {
      cart.add(sandwichA, quantity: 2);
      cart.add(sandwichB, quantity: 3);
      cart.remove(sandwichA, quantity: 1);
      cart.remove(sandwichB, quantity: 2);
      expect(cart.getQuantity(sandwichA), 1);
      expect(cart.getQuantity(sandwichB), 1);
      expect(cart.length, 2);
    });

    test('should not allow negative quantities', () {
      cart.add(sandwichA, quantity: 2);
      cart.remove(sandwichA, quantity: 5);
      expect(cart.getQuantity(sandwichA), 0);
      expect(cart.isEmpty, isTrue);
    });

    test('adding two Sandwich instances with same config merges into one entry',
        () {
      final s1 = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: false,
        breadType: BreadType.white,
      );
      final s2 = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: false,
        breadType: BreadType.white,
      );

      cart.add(s1, quantity: 1);
      cart.add(s2, quantity: 2);

      expect(cart.length, 1,
          reason: 'Equivalent sandwiches must merge into a single map entry');
      expect(cart.countOfItems, 3);
      expect(cart.getQuantity(s1), 3);
    });

    test('updateQuantity sets exact quantity and removes when set to 0', () {
      final s = Sandwich(
        type: SandwichType.chickenTeriyaki,
        isFootlong: true,
        breadType: BreadType.wheat,
      );

      cart.add(s, quantity: 2);
      expect(cart.getQuantity(s), 2);

      cart.updateQuantity(s, 5);
      expect(cart.getQuantity(s), 5);

      cart.updateQuantity(s, 0);
      expect(cart.getQuantity(s), 0);
      expect(cart.isEmpty, true);
    });

    test('remove decreases quantity or removes item when quantity goes to zero',
        () {
      final s = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: false,
        breadType: BreadType.white,
      );

      cart.add(s, quantity: 3);
      cart.remove(s, quantity: 1);
      expect(cart.getQuantity(s), 2);

      cart.remove(s, quantity: 2);
      expect(cart.getQuantity(s), 0);
      expect(cart.isEmpty, true);
    });

    test('totalPrice uses PricingRepository calculation', () {
      final repo = PricingRepository();

      final s = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.white,
      );

      cart.add(s, quantity: 3);
      final expected =
          repo.calculatePrice(quantity: 3, isFootlong: s.isFootlong);
      expect(cart.totalPrice, expected);
    });
  });
}
