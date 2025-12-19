import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sandwich_shop/main.dart' as app;
import 'package:sandwich_shop/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sandwich_shop/services/database_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Helper to wait for a finder to appear with a timeout.
  Future<void> waitForFinder(WidgetTester tester, Finder finder,
      {Duration timeout = const Duration(seconds: 5)}) async {
    final DateTime end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
    // Dump tree for diagnostics before failing
    debugDumpApp();
    throw Exception('Timed out waiting for finder: $finder');
  }

  group('order history flow', () {
    testWidgets('checkout creates saved order and appears in history',
        (WidgetTester tester) async {
      // Ensure a clean database for a deterministic test
      final String databasesPath = await getDatabasesPath();
      final String dbPath = join(databasesPath, 'sandwich_shop.db');
      // Close any cached database instance first to avoid stale handles
      try {
        await DatabaseService().reset();
      } catch (_) {}
      await deleteDatabase(dbPath);

      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Add a sandwich to cart
      final addToCartButton = find.widgetWithText(StyledButton, 'Add to Cart');
      await waitForFinder(tester, addToCartButton);
      await tester.ensureVisible(addToCartButton);
      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      // View cart and go to checkout
      final viewCartButton = find.widgetWithText(StyledButton, 'View Cart');
      await waitForFinder(tester, viewCartButton);
      await tester.ensureVisible(viewCartButton);
      await tester.tap(viewCartButton);
      await tester.pumpAndSettle();

      final checkoutButton = find.widgetWithText(StyledButton, 'Checkout');
      await waitForFinder(tester, checkoutButton);
      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();

      // Confirm payment
      final confirmPaymentButton = find.text('Confirm Payment');
      await waitForFinder(tester, confirmPaymentButton);
      await tester.tap(confirmPaymentButton);
      await tester.pumpAndSettle();

      // Wait for payment processing (2s inside app) + buffer
      await tester.pump(const Duration(seconds: 3));

      // Back on main order screen
      expect(find.text('Sandwich Counter'), findsOneWidget);

      // Navigate to Order History
      final orderHistoryButton =
          find.widgetWithText(StyledButton, 'Order History');
      await waitForFinder(tester, orderHistoryButton);
      await tester.ensureVisible(orderHistoryButton);
      await tester.tap(orderHistoryButton);
      await tester.pumpAndSettle();

      expect(find.text('Order History'), findsOneWidget);

      // Verify saved order details are displayed (order id and total)
      // Total for 1 default sandwich is expected to be £11.00
      expect(find.text('£11.00'), findsWidgets);

      final orderIdFinder = find.byWidgetPredicate((widget) {
        return widget is Text && (widget.data?.startsWith('ORD') ?? false);
      });

      expect(orderIdFinder, findsWidgets);
    });

    testWidgets('delete saved order and show empty state',
        (WidgetTester tester) async {
      // Ensure a clean database
      final String databasesPath = await getDatabasesPath();
      final String dbPath = join(databasesPath, 'sandwich_shop.db');
      // Close any cached database instance first to avoid stale handles
      try {
        await DatabaseService().reset();
      } catch (_) {}
      await deleteDatabase(dbPath);

      // Launch app and create an order via checkout
      app.main();
      await tester.pumpAndSettle();

      final addToCartButton = find.widgetWithText(StyledButton, 'Add to Cart');
      await waitForFinder(tester, addToCartButton);
      await tester.ensureVisible(addToCartButton);
      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      final viewCartButton = find.widgetWithText(StyledButton, 'View Cart');
      await waitForFinder(tester, viewCartButton);
      await tester.ensureVisible(viewCartButton);
      await tester.tap(viewCartButton);
      await tester.pumpAndSettle();

      final checkoutButton = find.widgetWithText(StyledButton, 'Checkout');
      await waitForFinder(tester, checkoutButton);
      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();

      final confirmPaymentButton = find.text('Confirm Payment');
      await waitForFinder(tester, confirmPaymentButton);
      await tester.tap(confirmPaymentButton);
      await tester.pumpAndSettle();

      // Wait for payment processing (2s inside app) + buffer
      await tester.pump(const Duration(seconds: 3));

      // Verify DB has the order
      final DatabaseService dbService = DatabaseService();
      final ordersBefore = await dbService.getOrders();
      expect(ordersBefore.isNotEmpty, isTrue,
          reason: 'There should be at least one saved order after checkout');

      // Delete the saved order (delete first)
      final int idToDelete = ordersBefore.first.id;
      await dbService.deleteOrder(idToDelete);

      final ordersAfter = await dbService.getOrders();
      expect(ordersAfter.isEmpty, isTrue,
          reason: 'Orders should be empty after deletion');

      // Navigate to Order History and verify empty state UI
      final orderHistoryButton =
          find.widgetWithText(StyledButton, 'Order History');
      await waitForFinder(tester, orderHistoryButton);
      await tester.ensureVisible(orderHistoryButton);
      await tester.tap(orderHistoryButton);
      await tester.pumpAndSettle();

      expect(find.text('Order History'), findsOneWidget);
      expect(find.text('No orders yet'), findsOneWidget);
      expect(
          find.widgetWithText(StyledButton, 'Back to Order'), findsOneWidget);
    });

    testWidgets('checkout failure and recovery', (WidgetTester tester) async {
      // Ensure a clean database
      final String databasesPath = await getDatabasesPath();
      final String dbPath = join(databasesPath, 'sandwich_shop.db');
      try {
        await DatabaseService().reset();
      } catch (_) {}
      await deleteDatabase(dbPath);

      // Launch app and go to checkout with one item
      app.main();
      await tester.pumpAndSettle();

      final addToCartButton = find.widgetWithText(StyledButton, 'Add to Cart');
      await waitForFinder(tester, addToCartButton);
      await tester.ensureVisible(addToCartButton);
      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      final viewCartButton = find.widgetWithText(StyledButton, 'View Cart');
      await waitForFinder(tester, viewCartButton);
      await tester.ensureVisible(viewCartButton);
      await tester.tap(viewCartButton);
      await tester.pumpAndSettle();

      final checkoutButton = find.widgetWithText(StyledButton, 'Checkout');
      await waitForFinder(tester, checkoutButton);
      await tester.ensureVisible(checkoutButton);
      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();

      // Simulate DB insert failure for the next insert
      DatabaseService.simulateInsertFailure = true;

      final confirmPaymentButton = find.text('Confirm Payment');
      await waitForFinder(tester, confirmPaymentButton);
      await tester.ensureVisible(confirmPaymentButton);
      await tester.tap(confirmPaymentButton);
      await tester.pumpAndSettle();

      // Wait for processing + buffer
      await tester.pump(const Duration(seconds: 3));

      // Expect an error SnackBar shown and still on Checkout screen
      expect(find.text('Failed to save order'), findsOneWidget);
      expect(find.text('Checkout'), findsOneWidget);

      // Now clear the simulate flag and retry, should succeed
      DatabaseService.simulateInsertFailure = false;
      await tester.tap(confirmPaymentButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // After successful retry we should be back on main order screen
      expect(find.text('Sandwich Counter'), findsOneWidget);

      // DB should now contain the saved order
      final DatabaseService dbService2 = DatabaseService();
      final orders = await dbService2.getOrders();
      expect(orders.isNotEmpty, isTrue);
    });
  });
}
