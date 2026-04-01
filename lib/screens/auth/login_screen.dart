// =============================================================================
// LOGIN SCREEN
// Owner: [assign to teammate]
// TODO: Build the login UI here
// =============================================================================

import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Must be at least 8 characters';

    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    if (!passwordRegex.hasMatch(value)) {
      return 'Include letters, numbers, and a sign (e.g., !@#)';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        // --- ADDED BRANDING TO THE TOP RIGHT ---
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                // Replace Icons.school with Image.asset('assets/logo.png') once you have one
                Image.asset('assets/images/mobile.png', width: 30,),
                const SizedBox(width: 6),
                const Text(
                  "CampusCollab",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
        // ---------------------------------------
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Welcome!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text("Please enter your details to continue."),
              const SizedBox(height: 32),

              // FULL NAME FIELD
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),

              // EMAIL FIELD
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || !value.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // PASSWORD FIELD
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  border: const OutlineInputBorder(),
                  helperText: 'Min. 8 chars, numbers & symbols',
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 32),

              // LOGIN BUTTON
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Login / Sign Up', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF5D5D5D),
        letterSpacing: 1.0,
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, required IconData prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(prefixIcon, color: Colors.grey[400]),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF0F2F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey[100]!),
        backgroundColor: const Color(0xFFF8F9FE),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildFooterSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text("|", style: TextStyle(color: Colors.grey[300], fontSize: 10)),
    );
  }
}
