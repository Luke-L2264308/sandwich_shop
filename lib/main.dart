import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/order_screen.dart';
import 'package:sandwich_shop/views/about_screen.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/providers/profile_provider.dart';
import 'package:sandwich_shop/state/navigation_provider.dart';
import 'widgets/app_shell.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileProvider>(
            create: (_) => ProfileProvider()),
        ChangeNotifierProvider<NavigationProvider>(
            create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'Sandwich Shop App',
        home: const AppShell(),
        routes: {
          '/about': (context) => const AboutScreen(),
        },
      ),
    );
  }
}
