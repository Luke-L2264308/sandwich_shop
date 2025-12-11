import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/providers/profile_provider.dart';
import 'package:sandwich_shop/views/profile_screen.dart';

void main() {
  testWidgets('Profile screen view -> edit -> validation -> save',
      (WidgetTester tester) async {
    // make provider fast for tests
    final provider = ProfileProvider(simulatedDelay: Duration.zero);
    // seed a known profile
    await provider.saveProfile(Profile(displayName: 'Bob', email: 'bob@example.com'));

    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileProvider>.value(
        value: provider,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    // allow widget tree to settle
    await tester.pumpAndSettle();

    // initial view mode shows name and email
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('bob@example.com'), findsOneWidget);

    // enter edit mode
    await tester.tap(find.byKey(const Key('editButton')));
    await tester.pumpAndSettle();

    // invalid email should show validation error and prevent save
    await tester.enterText(
        find.byKey(const Key('emailField')), 'invalid-email');
    await tester.tap(find.byKey(const Key('saveButton')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email'), findsOneWidget);

    // valid email -> save
    await tester.enterText(
        find.byKey(const Key('emailField')), 'newbob@example.com');
    await tester.tap(find.byKey(const Key('saveButton')));
    // wait for async save + UI updates
    await tester.pumpAndSettle();

    // Snackbar appears and view mode shows updated email
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('newbob@example.com'), findsOneWidget);
  });
}
