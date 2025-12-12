import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_styles.dart';
import 'package:sandwich_shop/models/cart.dart';

AppBar titleAppbar(String title, {Widget? actions}) {
  return AppBar(
    leading: Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 100,
        child: Image.asset('assets/images/logo.png'),
      ),
    ),
    title: Text(
      title,
      style: heading1,
    ),
    actions: actions != null ? [actions] : null,
  );
}

Widget shoppingCartDisplay() {
  return Consumer<Cart>(
    builder: (context, cart, child) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart),
            const SizedBox(width: 4),
            Text('${cart.countOfItems}'),
          ],
        ),
      );
    },
  );
}
