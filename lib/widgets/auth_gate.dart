import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/email_verification_screen.dart';
import '../screens/home/home_screen.dart';

/// Routes to HomeScreen, EmailVerificationScreen, or LoginScreen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    if (!auth.isLoggedIn) return const LoginScreen();
    if (!auth.isEmailVerified) return const EmailVerificationScreen();
    return const HomeScreen();
  }
}
