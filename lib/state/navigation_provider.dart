import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void selectIndex(int index) {
    if (index < 0) return;
    _selectedIndex = index;
    notifyListeners();
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    try {
      final ctx = scaffoldKey.currentContext;
      if (ctx != null) {
        // If a drawer is open, popping the route will close it.
        Navigator.of(ctx).maybePop();
      }
    } catch (_) {}
  }
}
