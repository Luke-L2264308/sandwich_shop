import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/views/edit_quantity_dialog.dart';

void main() {
  testWidgets('edit quantity dialog validates input and returns value on save',
      (WidgetTester tester) async {
    int? result;

    Widget host() {
      return MaterialApp(
        home: Builder(builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                child: const Text('Open'),
                onPressed: () async {
                  result = await showEditQuantityDialog(
                    context,
                    current: 2,
                    min: 1,
                    max: 10,
                  );
                },
              ),
            ),
          );
        }),
      );
    }

    await tester.pumpWidget(host());

    // Open dialog
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Enter invalid (non-integer)
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.text('Save'));
    await tester.pump(); // show validation
    expect(find.text('Please enter a valid integer'), findsOneWidget);

    // Enter out of bounds (0)
    await tester.enterText(find.byType(TextField), '0');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.textContaining('Enter a value between'), findsOneWidget);

    // Enter valid value
    await tester.enterText(find.byType(TextField), '5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 5);
  });
}
