import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/state/navigation_provider.dart';
import 'package:sandwich_shop/navigation/navigation_items.dart';
import '../views/order_screen.dart';
import '../views/cart_screen.dart';
import '../views/profile_screen.dart';
import '../views/about_screen.dart';
import '../models/cart.dart';

class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<NavigatorState> _innerNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(builder: (context, nav, _) {
      // Always provide an outer Scaffold so Drawer/ScaffoldMessenger and other
      // Material-dependent APIs are available to inner routes/pages.
      return Scaffold(
        key: nav.scaffoldKey,
        drawer: _buildDrawer(context, nav),
        body: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          if (width < AppShell.mobileBreakpoint) {
            // Mobile: show inner navigator full-screen; drawer accessible
            return _buildInnerNavigator();
          } else if (width < AppShell.tabletBreakpoint) {
            // Tablet: NavigationRail persistent
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: nav.selectedIndex,
                  onDestinationSelected: (i) => _onNavTap(context, nav, i),
                  labelType: NavigationRailLabelType.all,
                  destinations: navigationItems
                      .map((it) => NavigationRailDestination(
                          icon: Icon(it.icon), label: Text(it.label)))
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildInnerNavigator()),
              ],
            );
          } else {
            // Desktop: permanent panel
            return Row(
              children: [
                Container(
                  width: 260,
                  color: Theme.of(context).colorScheme.surface,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Sandwich Shop',
                              style: Theme.of(context).textTheme.titleLarge),
                        ),
                        Expanded(
                            child:
                                _buildNavList(context, nav, showLabels: true)),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildInnerNavigator()),
              ],
            );
          }
        }),
      );
    });
  }

  Widget _buildInnerNavigator() {
    return Navigator(
      key: _innerNavKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/cart':
            page = CartScreen(cart: Cart());
            break;
          case '/profile':
            page = const ProfileScreen();
            break;
          case '/about':
            page = const AboutScreen();
            break;
          case '/':
          default:
            page = const OrderScreen();
        }
        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }

  Widget _buildDrawer(BuildContext context, NavigationProvider nav) {
    return Drawer(
      child: SafeArea(child: _buildNavList(context, nav, showLabels: true)),
    );
  }

  Widget _buildNavList(BuildContext context, NavigationProvider nav,
      {bool showLabels = false}) {
    return ListView(
      children: navigationItems.asMap().entries.map((entry) {
        final i = entry.key;
        final it = entry.value;
        final selected = nav.selectedIndex == i;
        return ListTile(
          leading: Icon(it.icon),
          title: showLabels ? Text(it.label) : null,
          selected: selected,
          onTap: () => _onNavTap(context, nav, i),
        );
      }).toList(),
    );
  }

  void _onNavTap(BuildContext context, NavigationProvider nav, int index) {
    final item = navigationItems[index];
    nav.selectIndex(index);
    // close drawer if open
    try {
      nav.scaffoldKey.currentState?.closeDrawer();
    } catch (_) {}
    // navigate inner navigator
    if (_innerNavKey.currentState != null) {
      _innerNavKey.currentState!.pushReplacementNamed(item.route);
    }
  }
}
