import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/views/cart_screen.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/state/navigation_provider.dart';
import 'package:sandwich_shop/providers/profile_provider.dart';

void main() {
  

  testWidgets('remove button removes item and shows undo snackbar', (tester) async {
    final Cart cart = Cart();
    final sandwich = Sandwich(type: SandwichType.veggieDelight, isFootlong: true, breadType: BreadType.white);
    cart.add(sandwich, quantity: 1);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ],
        child: MaterialApp(home: CartScreen(cart: cart)),
      ),
    );

    // ensure item present
    expect(find.text('Veggie Delight'), findsWidgets);

    // tap the remove icon (tooltip 'Remove item')
    final removeFinder = find.byTooltip('Remove item');
    expect(removeFinder, findsOneWidget);
    await tester.tap(removeFinder);
    await tester.pumpAndSettle();

    // item should be removed from the UI
    expect(find.text('Veggie Delight'), findsNothing);

    // snackbar with removal message should appear
    expect(find.text('Veggie Delight removed'), findsOneWidget);
  });

  testWidgets('bulk update dialog applies and shows snackbar', (tester) async {
    final Cart cart = Cart();
    final s1 = Sandwich(type: SandwichType.veggieDelight, isFootlong: true, breadType: BreadType.white);
    final s2 = Sandwich(type: SandwichType.chickenTeriyaki, isFootlong: true, breadType: BreadType.white);
    cart.add(s1, quantity: 1);
    cart.add(s2, quantity: 1);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ],
        child: MaterialApp(home: CartScreen(cart: cart)),
      ),
    );

    // tap Bulk Update
    final bulkFinder = find.text('Bulk Update');
    expect(bulkFinder, findsOneWidget);
    await tester.tap(bulkFinder);
    await tester.pumpAndSettle();

    // enter 3 in dialog
    final textField = find.byType(TextField).first;
    await tester.enterText(textField, '3');
    await tester.pumpAndSettle();

    // tap Apply button
    final applyBtn = find.widgetWithText(ElevatedButton, 'Apply');
    expect(applyBtn, findsOneWidget);
    await tester.tap(applyBtn);
    await tester.pumpAndSettle();

    // snackbar should show confirmation
    expect(find.text('All items set to 3'), findsOneWidget);
  });
}
