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

  Future<void> sendVerificationCode({
    required String toEmail,
    required String name,
    required String code,
  }) =>
      _send(
        templateId: _verifyTplId,
        params: {
          'to_email': toEmail,
          'name': name.isEmpty ? 'there' : name,
          'code': code,
        },
      );

  Future<void> sendPasswordResetCode({
    required String toEmail,
    required String name,
    required String code,
  }) =>
      _send(
        templateId: _resetTplId,
        params: {
          'to_email': toEmail,
          'name': name.isEmpty ? 'there' : name,
          'code': code,
        },
      );

  Future<void> _send({
    required String templateId,
    required Map<String, String> params,
  }) async {
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
      throw Exception('Email send failed (${res.statusCode}): ${res.body}');
    }
  }
}
