// =============================================================================
// HOME SCREEN
// Owner: [assign to teammate]
// TODO: Build the home UI here
// =============================================================================

import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.chats),
              child: const Text('Go to Chats'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: const Text('Go to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
