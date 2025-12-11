import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/state/navigation_provider.dart';

void main() {
  // Ensure the widgets binding is initialized so Scaffold/Navigator
  // operations (used by NavigationProvider) do not throw in tests.
  TestWidgetsFlutterBinding.ensureInitialized();
  group('NavigationProvider', () {
    test('selectIndex updates selectedIndex and notifies listeners', () {
      final provider = NavigationProvider();
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      expect(provider.selectedIndex, 0);
      provider.selectIndex(2);
      expect(provider.selectedIndex, 2);
      expect(notified, isTrue);
    });

    test('selectIndex with negative index does not change state or notify', () {
      final provider = NavigationProvider();
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      expect(provider.selectedIndex, 0);
      provider.selectIndex(-1);
      expect(provider.selectedIndex, 0);
      expect(notified, isFalse);
    });

    test('openDrawer and closeDrawer are safe when scaffold not attached', () {
      final provider = NavigationProvider();

      // Should not throw even though scaffoldKey isn't attached to a Scaffold
      expect(() => provider.openDrawer(), returnsNormally);
      expect(() => provider.closeDrawer(), returnsNormally);
    });
  });
}
