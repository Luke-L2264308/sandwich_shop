import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/order_screen.dart';
import 'package:sandwich_shop/views/about_screen.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/providers/profile_provider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileProvider>(
      create: (_) => ProfileProvider(),
      child: MaterialApp(
        title: 'Sandwich Shop App',
        home: const OrderScreen(maxQuantity: 5),
        routes: {
          '/about': (context) => const AboutScreen(),
        },
      ),
    );
  }
}
