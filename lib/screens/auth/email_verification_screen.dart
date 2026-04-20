import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _resending = false;
  bool _resentSuccess = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final auth = context.read<AppAuthProvider>();
      final success = await auth.verifyEmailCode(code);

      if (success && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'Verification failed. Please check the code.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _resentSuccess = false;
    });
    try {
      final auth = context.read<AppAuthProvider>();
      final success = await auth.sendVerificationEmail();
      if (mounted && success) {
        setState(() => _resentSuccess = true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'Could not resend code.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not resend: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AppAuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = context.read<AppAuthProvider>().user?.email ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // ── Icon ───────────────────────────────────────────────────────
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mark_email_unread_outlined,
                    size: 48, color: AppTheme.primary),
              ),
              const SizedBox(height: 28),

              // ── Heading ────────────────────────────────────────────────────
              Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a 6-digit code to',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),

              // ── OTP INPUT FIELD ──────────────────────────────────────────
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: TextStyle(
                  fontSize: 28, 
                  letterSpacing: 12, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                  counterText: '',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Verify Button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isVerifying 
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Verify Account",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
              
              const SizedBox(height: 16),

              // ── Resend Button ──────────────────────────────────────────────
              TextButton(
                onPressed: _resending ? null : _resend,
                child: _resending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        _resentSuccess ? 'Code Resent!' : 'Resend Code',
                        style: TextStyle(
                          color: _resentSuccess ? Colors.green : AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(height: 40),
              GestureDetector(
                onTap: _logout,
                child: Text(
                  'Use a different account',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
