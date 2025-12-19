import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sandwich_shop/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:sandwich_shop/widgets/common_widgets.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> waitForFinder(WidgetTester tester, Finder finder,
      {Duration timeout = const Duration(seconds: 5)}) async {
    final DateTime end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
    debugDumpApp();
    throw Exception('Timed out waiting for finder: $finder');
  }

  group('profile flow round-trip', () {
    testWidgets('save profile shows welcome SnackBar',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Open Profile screen
      final profileButton = find.widgetWithText(StyledButton, 'Profile');
      await waitForFinder(tester, profileButton);
      await tester.ensureVisible(profileButton);
      await tester.tap(profileButton);
      await tester.pumpAndSettle();

      // Find name & location fields by matching their label text widgets,
      // and then find the corresponding TextField widgets.
      final nameField = find.byWidgetPredicate((w) {
        return w is TextField && w.decoration?.labelText == 'Your Name';
      });
      final locationField = find.byWidgetPredicate((w) {
        return w is TextField &&
            w.decoration?.labelText == 'Preferred Location';
      });

      await waitForFinder(tester, nameField);
      await tester.enterText(nameField, 'Alice');
      await tester.enterText(locationField, 'London');
      await tester.pumpAndSettle();

      // Tap Save Profile
      final saveButton = find.widgetWithText(ElevatedButton, 'Save Profile');
      await waitForFinder(tester, saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Expect a welcome SnackBar that includes the provided name and location
      final welcomeText = find.text('Welcome, Alice! Ordering from London');
      await waitForFinder(tester, welcomeText);
      expect(welcomeText, findsOneWidget);
    });

    testWidgets('validation shows error when fields empty',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final profileButton = find.widgetWithText(StyledButton, 'Profile');
      await waitForFinder(tester, profileButton);
      await tester.ensureVisible(profileButton);
      await tester.tap(profileButton);
      await tester.pumpAndSettle();

      // Ensure fields are empty then tap Save
      final saveButton = find.widgetWithText(ElevatedButton, 'Save Profile');
      await waitForFinder(tester, saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final validationText = find.text('Please fill in all fields');
      await waitForFinder(tester, validationText);
      expect(validationText, findsOneWidget);
    });
  });
}
