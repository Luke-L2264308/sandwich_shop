import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/views/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsScreen', () {
    setUp(() {
      // Set initial values for the mock SharedPreferences
      SharedPreferences.setMockInitialValues({'fontSize': 16.0});
    });

    testWidgets('shows loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Expect to find a loading indicator while settings are being loaded
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays correctly after loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Wait for the settings to load
      await tester.pumpAndSettle();

      // Check for the main widgets on the screen
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Font Size'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.textContaining('Current size:'), findsOneWidget);
      expect(
          find.widgetWithText(ElevatedButton, 'Back to Order'), findsOneWidget);
    });

    testWidgets('slider updates font size and saves it',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the slider to change its value to the center (22.0)
      await tester.tap(find.byType(Slider));
      await tester.pumpAndSettle();

      // Check if the font size text is updated on the screen
      expect(find.textContaining('18px'), findsOneWidget);

      // Verify that the new font size was saved to SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('fontSize'), 18.0);
    });

    testWidgets('Done button is enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the "Done" button and check if it's enabled
      final Finder doneButtonFinder =
          find.widgetWithText(ElevatedButton, 'Back to Order');
      expect(doneButtonFinder, findsOneWidget);

      final ElevatedButton doneButton =
          tester.widget<ElevatedButton>(doneButtonFinder);
      expect(doneButton.onPressed, isNotNull);
    });
  });
}
