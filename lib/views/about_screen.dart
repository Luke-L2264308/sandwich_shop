import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/state/navigation_provider.dart';
import 'package:sandwich_shop/views/app_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: MediaQuery.of(context).size.width < 1024
            ? IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Open navigation',
                onPressed: () =>
                    Provider.of<NavigationProvider>(context, listen: false)
                        .openDrawer(),
              )
            : null,
        title: const Text('About Us', style: heading1),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome to Sandwich Shop!', style: heading2),
            SizedBox(height: 20),
            Text(
              'We are a family-owned business dedicated to serving the best sandwiches in town. ',
              style: normalText,
            ),
          ],
        ),
      ),
    );
  }
}
