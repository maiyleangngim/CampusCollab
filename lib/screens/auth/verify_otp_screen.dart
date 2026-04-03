// =============================================================================
// VERIFY OTP SCREEN
// =============================================================================
// Used for both email verification (after registration) and
// identity confirmation (before password reset).
// Can be constructed with explicit args OR with autoSendOnLoad = true
// (when launched by AuthGate for a user who is logged in but unverified).

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/email_service.dart';
import '../../services/otp_service.dart';
import '../../theme/app_theme.dart';
import 'reset_password_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  /// When provided, the OTP has already been sent and the cooldown starts.
  final String? initialUid;
  final String? initialEmail;
  final String? initialName;
  final OtpPurpose purpose;

  /// When true (AuthGate path) the screen loads user data from FirebaseAuth
  /// and Firestore, then sends a fresh OTP automatically.
  final bool autoSendOnLoad;

  const VerifyOtpScreen({
    super.key,
    this.initialUid,
    this.initialEmail,
    this.initialName,
    this.purpose = OtpPurpose.emailVerification,
    this.autoSendOnLoad = false,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpService = OtpService();
  final _emailService = EmailService();

  late String _uid;
  late String _email;
  late String _name;

  // 6 digit boxes
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = true;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _error;

  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _setup();

    // Backspace-on-empty → move to previous box
    for (int i = 1; i < 6; i++) {
      final idx = i;
      _focusNodes[idx].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[idx].text.isEmpty) {
          _focusNodes[idx - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  Future<void> _setup() async {
    if (widget.autoSendOnLoad) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      _uid = user.uid;
      _email = user.email ?? '';
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        _name = doc.data()?['displayName'] as String? ?? '';
      } catch (_) {
        _name = '';
      }
      await _sendOtp(startCooldown: true);
    } else {
      _uid = widget.initialUid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
      _email = widget.initialEmail ?? '';
      _name = widget.initialName ?? '';
      _startCooldown();
    }

    if (mounted) {
      setState(() => _isLoading = false);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _focusNodes[0].requestFocus());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  void _startCooldown() {
    _resendCooldown = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) t.cancel();
      });
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _sendOtp({bool startCooldown = false}) async {
    final code = await _otpService.generateAndStore(_uid, widget.purpose);
    if (widget.purpose == OtpPurpose.emailVerification) {
      await _emailService.sendVerificationCode(
          toEmail: _email, name: _name, code: code);
    } else {
      await _emailService.sendPasswordResetCode(
          toEmail: _email, name: _name, code: code);
    }
    if (startCooldown && mounted) _startCooldown();
  }

  // ── Verify ──────────────────────────────────────────────────────────────────

  Future<void> _verify() async {
    if (_code.length < 6) {
      setState(() => _error = 'Please enter all 6 digits.');
      return;
    }
    setState(() {
      _isVerifying = true;
      _error = null;
    });

    // Capture context-dependent objects before any awaits
    final provider = context.read<AppAuthProvider>();
    final nav = Navigator.of(context);

    try {
      final ok = await _otpService.verify(_uid, _code, widget.purpose);
      if (!mounted) return;

      if (ok) {
        if (widget.purpose == OtpPurpose.emailVerification) {
          await provider.refreshEmailVerified();
          if (!mounted) return;
          nav.pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
        } else {
          try {
            await FirebaseAuth.instance
                .sendPasswordResetEmail(email: _email);
          } catch (_) {}
          if (!mounted) return;
          nav.pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(email: _email)),
            (r) => false,
          );
        }
      } else {
        for (final c in _controllers) { c.clear(); }
        _focusNodes[0].requestFocus();
        setState(() => _error = 'Invalid or expired code. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Verification failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  // ── Resend ───────────────────────────────────────────────────────────────────

  Future<void> _resend() async {
    setState(() {
      _isResending = true;
      _error = null;
    });
    try {
      await _sendOtp();
      if (mounted) {
        _startCooldown();
        for (final c in _controllers) { c.clear(); }
        _focusNodes[0].requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('A new code has been sent to your email.'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to resend. Please try again.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isVerification = widget.purpose == OtpPurpose.emailVerification;
    final maskedEmail = _maskEmail(_email);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: !isVerification,
        leading: isVerification
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // ── Icon ──────────────────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    color: AppTheme.primary, size: 40),
              ),
              const SizedBox(height: 28),

              // ── Title ─────────────────────────────────────────────────────
              Text(
                isVerification ? 'Verify your email' : 'Enter reset code',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              Text(
                'We sent a 6-digit code to\n$maskedEmail',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // ── OTP boxes ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  6,
                  (i) => _OtpBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    onInput: (val) {
                      setState(() => _error = null);
                      if (val.isNotEmpty && i < 5) {
                        _focusNodes[i + 1].requestFocus();
                      }
                      if (_code.length == 6) {
                        Future.microtask(_verify);
                      }
                    },
                  ),
                ),
              ),

              // ── Error ─────────────────────────────────────────────────────
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),

              // ── Verify button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verify,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Verify Code',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),

              // ── Resend ────────────────────────────────────────────────────
              if (_resendCooldown > 0)
                Text(
                  'Resend code in ${_resendCooldown}s',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                )
              else
                GestureDetector(
                  onTap: _isResending ? null : _resend,
                  child: _isResending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          "Didn't receive a code? Resend",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),

              const SizedBox(height: 40),

              // ── Disclaimer ────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD54F)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFFF57F17), size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "If you didn't request this code, you can safely ignore "
                        'this message. Your account will remain secure.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6D4C00),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Sign out (verification only) ──────────────────────────────
              if (isVerification) ...[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    final nav = Navigator.of(context);
                    await context.read<AppAuthProvider>().logout();
                    nav.pushNamedAndRemoveUntil(
                        AppRoutes.login, (r) => false);
                  },
                  child: const Text(
                    'Sign out',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  static String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return email;
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }
}

// ── OTP digit box ──────────────────────────────────────────────────────────────

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onInput;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onInput,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = widget.focusNode.hasFocus;
    return Container(
      width: 44,
      height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFocus ? AppTheme.primary : AppTheme.divider,
          width: hasFocus ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (val) {
          if (val.length > 1) {
            widget.controller.text = val[val.length - 1];
            widget.controller.selection =
                const TextSelection.collapsed(offset: 1);
          }
          widget.onInput(widget.controller.text);
        },
      ),
    );
  }
}
