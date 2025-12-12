import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/views/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/models/cart.dart';

void main() {
  group('ProfileScreen', () {
    testWidgets('displays initial UI elements correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Enter your details:'), findsOneWidget);
      expect(find.text('Your Name'), findsOneWidget);
      expect(find.text('Preferred Location'), findsOneWidget);
      expect(find.text('Save Profile'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('text fields accept input correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      final Finder nameFieldFinder =
          find.widgetWithText(TextField, 'Your Name');
      final Finder locationFieldFinder =
          find.widgetWithText(TextField, 'Preferred Location');

      await tester.enterText(nameFieldFinder, 'John Doe');
      await tester.enterText(locationFieldFinder, 'London');
      await tester.pump();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('London'), findsOneWidget);
    });

    testWidgets('shows validation error when name field is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      final Finder locationFieldFinder =
          find.widgetWithText(TextField, 'Preferred Location');
      final Finder saveButtonFinder = find.text('Save Profile');

      await tester.enterText(locationFieldFinder, 'London');
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('shows validation error when location field is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      final Finder nameFieldFinder =
          find.widgetWithText(TextField, 'Your Name');
      final Finder saveButtonFinder = find.text('Save Profile');

      await tester.enterText(nameFieldFinder, 'John Doe');
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('shows validation error when both fields are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      final Finder saveButtonFinder = find.text('Save Profile');

      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('trims whitespace from input fields',
        (WidgetTester tester) async {
      Map<String, String>? result;
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.push<Map<String, String>>(
                    context,
                    MaterialPageRoute<Map<String, String>>(
                      builder: (BuildContext context) => const ProfileScreen(),
                    ),
                  );
                },
                child: const Text('Go to Profile'),
              ),
            );
          },
        ),
      )
        ),
      );
      
      await tester.tap(find.text('Go to Profile'));
      await tester.pumpAndSettle();

      final Finder nameFieldFinder =
          find.widgetWithText(TextField, 'Your Name');
      final Finder locationFieldFinder =
          find.widgetWithText(TextField, 'Preferred Location');
      final Finder saveButtonFinder = find.text('Save Profile');

      await tester.enterText(nameFieldFinder, '  John Doe  ');
      await tester.enterText(locationFieldFinder, '  London  ');
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!['name'], equals('John Doe'));
      expect(result!['location'], equals('London'));
    });

    testWidgets('returns profile data when both fields are filled',
        (WidgetTester tester) async {
      Map<String, String>? result;
      

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.push<Map<String, String>>(
                    context,
                    MaterialPageRoute<Map<String, String>>(
                      builder: (BuildContext context) => const ProfileScreen(),
                    ),
                  );
                },
                child: const Text('Go to Profile'),
              ),
            );
          },
        ),
      )
        ),
      );
      await tester.tap(find.text('Go to Profile'));
      await tester.pumpAndSettle();

      final Finder nameFieldFinder =
          find.widgetWithText(TextField, 'Your Name');
      final Finder locationFieldFinder =
          find.widgetWithText(TextField, 'Preferred Location');
      final Finder saveButtonFinder = find.text('Save Profile');

      await tester.enterText(nameFieldFinder, 'Jane Smith');
      await tester.enterText(locationFieldFinder, 'Manchester');
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!['name'], equals('Jane Smith'));
      expect(result!['location'], equals('Manchester'));
    });

    testWidgets('text fields have proper decoration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      final Finder nameFieldFinder =
          find.widgetWithText(TextField, 'Your Name');
      final Finder locationFieldFinder =
          find.widgetWithText(TextField, 'Preferred Location');

      final TextField nameField = tester.widget<TextField>(nameFieldFinder);
      final TextField locationField =
          tester.widget<TextField>(locationFieldFinder);

      expect(nameField.decoration?.labelText, equals('Your Name'));
      expect(nameField.decoration?.border, isA<OutlineInputBorder>());
      expect(locationField.decoration?.labelText, equals('Preferred Location'));
      expect(locationField.decoration?.border, isA<OutlineInputBorder>());
    });

    testWidgets('save button is always enabled', (WidgetTester tester) async {
     await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      final Finder saveButtonFinder = find.byType(ElevatedButton);
      final ElevatedButton saveButton =
          tester.widget<ElevatedButton>(saveButtonFinder);

      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('handles special characters in input fields',
        (WidgetTester tester) async {
      Map<String, String>? result;
     

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.push<Map<String, String>>(
                    context,
                    MaterialPageRoute<Map<String, String>>(
                      builder: (BuildContext context) => const ProfileScreen(),
                    ),
                  );
                },
                child: const Text('Go to Profile'),
              ),
            );
          },
        ),
      )
        ),
      );
      await tester.tap(find.text('Go to Profile'));
      await tester.pumpAndSettle();

      final Finder nameFieldFinder =
          find.widgetWithText(TextField, 'Your Name');
      final Finder locationFieldFinder =
          find.widgetWithText(TextField, 'Preferred Location');
      final Finder saveButtonFinder = find.text('Save Profile');

      await tester.enterText(nameFieldFinder, 'José María');
      await tester.enterText(locationFieldFinder, 'São Paulo');
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!['name'], equals('José María'));
      expect(result!['location'], equals('São Paulo'));
    });

    testWidgets('column has correct cross axis alignment',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      final Finder columnFinder = find.byType(Column);
      final Column column = tester.widget<Column>(columnFinder);

      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.stretch));
    });

    testWidgets('snackbar has correct duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      final Finder saveButtonFinder = find.text('Save Profile');

      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Please fill in all fields'), findsOneWidget);

      final Finder snackBarFinder = find.byType(SnackBar);
      final SnackBar snackBar = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBar.duration, equals(const Duration(seconds: 2)));
    });

    testWidgets('handles empty strings after trimming',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      final Finder nameFieldFinder =
          find.widgetWithText(TextField, 'Your Name');
      final Finder locationFieldFinder =
          find.widgetWithText(TextField, 'Preferred Location');
      final Finder saveButtonFinder = find.text('Save Profile');

      await tester.enterText(nameFieldFinder, '   ');
      await tester.enterText(locationFieldFinder, '   ');
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });
  });
}
