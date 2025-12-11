import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/views/checkout_screen.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';

void main() {
  group('CheckoutScreen', () {
    testWidgets('shows order summary, items and total', (WidgetTester tester) async {
      final cart = Cart();
      final s1 = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.white,
      );
      final s2 = Sandwich(
        type: SandwichType.chickenTeriyaki,
        isFootlong: false,
        breadType: BreadType.wheat,
      );
      cart.add(s1, quantity: 2);
      cart.add(s2, quantity: 1);

      await tester.pumpWidget(MaterialApp(home: CheckoutScreen(cart: cart)));
      await tester.pumpAndSettle();

      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.textContaining('2x ${s1.name}'), findsOneWidget);
      expect(find.textContaining('1x ${s2.name}'), findsOneWidget);
      // Total row present
      expect(find.textContaining('Total:'), findsOneWidget);
      expect(find.textContaining('£'), findsWidgets);
    });

    testWidgets('tapping Confirm Payment shows processing UI and then pops', (WidgetTester tester) async {
      final cart = Cart();
      final s = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.white,
      );
      cart.add(s, quantity: 1);

      await tester.pumpWidget(MaterialApp(home: CheckoutScreen(cart: cart)));
      await tester.pumpAndSettle();

      // Tap Confirm Payment
      final confirmFinder = find.text('Confirm Payment');
      expect(confirmFinder, findsOneWidget);
      await tester.tap(confirmFinder);
      await tester.pump(); // allow setState -> _isProcessing true

      // Processing UI should appear
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Processing payment...'), findsOneWidget);

      // Wait the simulated processing delay (2s) and allow pop to occur
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // After processing the screen should have been popped (no Order Summary)
      expect(find.text('Order Summary'), findsNothing);
    });
  });
}
