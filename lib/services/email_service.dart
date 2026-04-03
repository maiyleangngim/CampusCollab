import 'dart:convert';
import 'package:http/http.dart' as http;

/// Sends transactional emails via EmailJS.
///
/// Setup (free tier — 200 emails/month):
///   1. Sign up at https://www.emailjs.com
///   2. Add an Email Service (Gmail, Outlook, etc.)
///   3. Create two templates:
///        • Verification  — template variables: {{to_email}}, {{code}}, {{name}}
///        • Password Reset — template variables: {{to_email}}, {{code}}, {{name}}
///   4. Replace the four constants below with your credentials.
class EmailService {
  // ── Configuration ───────────────────────────────────────────────────────────
  static const _publicKey    = 'hbGDMWJqn6xiA0lWL';
  static const _serviceId    = 'service_123m6c2';
  static const _verifyTplId  = 'template_ysoxi8d';
  static const _resetTplId   = 'template_0syd9he';
  // ────────────────────────────────────────────────────────────────────────────

  static const _endpoint =
      'https://api.emailjs.com/api/v1.0/email/send';

  static const _appName = 'CampusCollab';
  static const _otpValidityMinutes = 15;

  Future<void> sendVerificationCode({
    required String toEmail,
    required String name,
    required String code,
  }) {
    final recipient = toEmail.trim();
    final displayName = name.trim().isEmpty ? 'there' : name.trim();
    final expiresAt = _formatExpiryTime(
      DateTime.now().add(const Duration(minutes: _otpValidityMinutes)),
    );

    return _send(
      templateId: _verifyTplId,
      params: {
        // Include common key variants so different EmailJS templates still resolve recipient.
        'to_email': recipient,
        'email': recipient,
        'toEmail': recipient,
        'name': displayName,
        'code': code,
        'app_name': _appName,
        'otp_validity_minutes': '$_otpValidityMinutes',
        'expires_at': expiresAt,
        'subject': '$_appName verification code',
        'title': 'Verify your email',
        'preheader': 'Use this one-time code to verify your $_appName account.',
        'intro': 'Use the verification code below to complete your sign up.',
        'body_text':
            'Your one-time verification code is $code. This code expires in $_otpValidityMinutes minutes (at $expiresAt).',
        'footer_text': 'Thanks for choosing $_appName.',
      },
    );
  }

  Future<void> sendPasswordResetCode({
    required String toEmail,
    required String name,
    required String code,
  }) {
    final recipient = toEmail.trim();
    final displayName = name.trim().isEmpty ? 'there' : name.trim();
    final expiresAt = _formatExpiryTime(
      DateTime.now().add(const Duration(minutes: _otpValidityMinutes)),
    );

    return _send(
      templateId: _resetTplId,
      params: {
        'to_email': recipient,
        'email': recipient,
        'toEmail': recipient,
        'name': displayName,
        'code': code,
        'app_name': _appName,
        'otp_validity_minutes': '$_otpValidityMinutes',
        'expires_at': expiresAt,
        'subject': '$_appName password reset code',
        'title': 'Reset your password',
        'preheader': 'Use this one-time code to continue resetting your $_appName password.',
        'intro': 'Use this code to verify your identity before resetting your password.',
        'body_text':
            'Your password reset code is $code. This code expires in $_otpValidityMinutes minutes (at $expiresAt).',
        'footer_text': 'Once verified, we will send you the password reset link.',
      },
    );
  }

  Future<void> _send({
    required String templateId,
    required Map<String, String> params,
  }) async {
    final recipient = (params['to_email'] ?? params['email'] ?? '').trim();
    if (recipient.isEmpty) {
      throw Exception('Cannot send OTP email: recipient address is empty.');
    }

    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'origin': 'http://localhost',
      },
      body: jsonEncode({
        'service_id': _serviceId,
        'template_id': templateId,
        'user_id': _publicKey,
        'template_params': params,
      }),
    );
    if (res.statusCode != 200) {
      if (res.statusCode == 422 &&
          res.body.toLowerCase().contains('recipients address is empty')) {
        throw Exception(
          'Email template recipient is not configured. In EmailJS, map the To field to {{to_email}} (or {{email}}).',
        );
      }
      throw Exception('Email send failed (${res.statusCode}): ${res.body}');
    }
  }

  static String _formatExpiryTime(DateTime dt) {
    final hour24 = dt.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = hour24 >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $suffix';
  }
}
