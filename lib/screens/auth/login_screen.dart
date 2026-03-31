import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF), // Light bluish background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              children: [
                // ── MAIN FORM CARD ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Pick up where you left off with your study groups.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // UNIVERSITY EMAIL LABEL & FIELD
                        _buildLabel("UNIVERSITY EMAIL"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          decoration: _buildInputDecoration(
                            hintText: "name@university.edu",
                            prefixIcon: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // PASSWORD LABEL & FIELD
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel("PASSWORD"),
                            GestureDetector(
                              onTap: () {
                                // TODO: Forgot password
                              },
                              child: const Text(
                                "Forgot password?",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA67C00), // Goldish color from design
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: _buildInputDecoration(
                            hintText: "••••••••",
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey[400],
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // LOG IN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, AppRoutes.home);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3D31FF), // Vibrant blue
                              foregroundColor: Colors.white,            // <--- Added this to make text white
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFF3D31FF).withOpacity(0.4),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Log In",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // OR CONTINUE WITH
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[200])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "OR CONTINUE WITH",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400],
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[200])),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // SOCIAL BUTTONS
                        Row(
                          children: [
                            Expanded(child: _buildSocialButton("Google", Icons.g_mobiledata_rounded)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildSocialButton("SSO", Icons.laptop_mac_rounded)),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // FOOTER LINK
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Color(0xFF3D31FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // BOTTOM LINKS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFooterLink("PRIVACY POLICY"),
                    _buildFooterSeparator(),
                    _buildFooterLink("TERMS OF SERVICE"),
                    _buildFooterSeparator(),
                    _buildFooterLink("SUPPORT"),
                  ],
                ),
              ],
            ),
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
