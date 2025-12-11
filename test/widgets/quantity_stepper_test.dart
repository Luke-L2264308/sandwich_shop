import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/views/cart_screen.dart';

void main() {
  testWidgets('QuantityStepper increments and decrements and respects max',
      (WidgetTester tester) async {
    // Test host that holds quantity state and rebuilds the stepper
    int qty = 1;
    Widget buildTestApp() {
      return MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(builder: (context, setState) {
            return QuantityStepper(
              quantity: qty,
              min: 1,
              max: 2,
              onChanged: (newQty) async {
                setState(() => qty = newQty);
              },
            );
          }),
        ),
      );
    }

    await tester.pumpWidget(buildTestApp());
    expect(find.text('1'), findsOneWidget);

    // Tap add -> becomes 2
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);

    // Tap add again -> should stay at max (2)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);

    // Tap remove -> becomes 1
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });
}
