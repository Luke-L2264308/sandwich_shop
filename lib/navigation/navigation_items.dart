import 'package:flutter/material.dart';

class NavigationItem {
  final String id;
  final String label;
  final IconData icon;
  final String route;

  const NavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
  });
}

const List<NavigationItem> navigationItems = [
  NavigationItem(id: 'home', label: 'Order', icon: Icons.home, route: '/'),
  NavigationItem(
      id: 'cart', label: 'Cart', icon: Icons.shopping_cart, route: '/cart'),
  NavigationItem(
      id: 'profile', label: 'Profile', icon: Icons.person, route: '/profile'),
  NavigationItem(
      id: 'about', label: 'About', icon: Icons.info, route: '/about'),
];
