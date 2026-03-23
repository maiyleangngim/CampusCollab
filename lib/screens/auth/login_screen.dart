// =============================================================================
// LOGIN SCREEN
// Owner: [assign to teammate]
// TODO: Build the login UI here
// =============================================================================

import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
          child: const Text('Go to Home'),
        ),
      ),
    );
  }
}
