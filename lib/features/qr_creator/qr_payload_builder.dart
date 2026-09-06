import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/features/qr_creator/qr_data_type.dart';

/// Input values collected by the QR Creator form for a single QR.
class QrInput {
  const QrInput({
    required this.type,
    this.url = '',
    this.phone = '',
    this.text = '',
    this.email = '',
    this.subject = '',
    this.message = '',
  });

  final QrDataType type;
  final String url;
  final String phone;
  final String text;
  final String email;
  final String subject;
  final String message;

  QrInput copyWith({QrDataType? type}) => QrInput(
      type: type ?? this.type,
      url: url,
      phone: phone,
      text: text,
      email: email,
      subject: subject,
      message: message);
}

/// Builds the machine-readable QR payload for a given [QrInput].
///
/// Separated from the UI so more payload types can be added (WhatsApp,
/// Wi-Fi, vCard / contact, location, calendar events, UPI / payments,
/// social media links) without touching widgets.
///
/// Payload conventions:
/// - Web URL  → the URL itself (normalized, no extra text).
/// - Phone    → `tel:+218910461043`
/// - Text     → the raw text.
/// - Email    → `mailto:address?subject=…&body=…` (URL-encoded).
/// - SMS      → `sms:+218910461043?body=…` (URL-encoded).
class QrPayloadBuilder {
  const QrPayloadBuilder._();

  /// Normalizes a user-entered URL: trims whitespace, adds `https://`
  /// when the scheme is missing.
  static String normalizeUrl(String value) {
    var url = value.trim();
    if (url.isEmpty) return url;
    if (!url.contains('://')) url = 'https://$url';
    return url;
  }

  /// Returns true when [value] is a valid http(s) absolute URL.
  static bool isUrl(String value) {
    final uri = Uri.tryParse(normalizeUrl(value));
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty &&
        uri.host.contains('.');
  }

  /// Returns the canonical payload for [input].
  ///
  /// Throws [ArgumentError] for an unsupported type.
  static String buildPayload(QrInput input) {
    switch (input.type) {
      case QrDataType.webUrl:
        return normalizeUrl(input.url);
      case QrDataType.phone:
        return 'tel:${input.phone.trim()}';
      case QrDataType.text:
        return input.text;
      case QrDataType.email:
        final sb = StringBuffer('mailto:${input.email.trim()}');
        final params = <String>[];
        if (input.subject.trim().isNotEmpty) {
          params.add('subject=${Uri.encodeComponent(input.subject.trim())}');
        }
        if (input.message.trim().isNotEmpty) {
          params.add('body=${Uri.encodeComponent(input.message.trim())}');
        }
        if (params.isNotEmpty) {
          sb.write('?${params.join('&')}');
        }
        return sb.toString();
      case QrDataType.sms:
        final sb = StringBuffer('sms:${input.phone.trim()}');
        final message = input.message.trim();
        if (message.isNotEmpty) {
          sb.write('?body=${Uri.encodeComponent(message)}');
        }
        return sb.toString();
    }
  }

  /// Validates [input]; returns `null` when valid, or a localized
  /// error message key for the offending field.
  static String? validate(QrInput input) {
    switch (input.type) {
      case QrDataType.webUrl:
        final url = input.url.trim();
        if (url.isEmpty) return L.requiredField;
        if (!isUrl(url)) return L.invalidUrl;
        return null;
      case QrDataType.phone:
        final phone = input.phone.trim();
        if (phone.isEmpty) return L.requiredField;
        final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
        if (digits.isEmpty || digits.length < 7) return L.invalidPhone;
        return null;
      case QrDataType.text:
        return input.text.trim().isEmpty ? L.requiredField : null;
      case QrDataType.email:
        final email = input.email.trim();
        if (email.isEmpty) return L.requiredField;
        final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        return re.hasMatch(email) ? null : L.invalidUrl;
      case QrDataType.sms:
        final phone = input.phone.trim();
        if (phone.isEmpty) return L.requiredField;
        final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
        if (digits.isEmpty || digits.length < 7) return L.invalidPhone;
        return null;
    }
  }

  /// Default placeholder text for the type's primary field.
  static String placeholderFor(QrDataType type) => switch (type) {
        QrDataType.webUrl => 'https://example.com',
        QrDataType.phone => '+218910461043',
        QrDataType.text => 'Hello from Soultech Vending',
        QrDataType.email => 'name@example.com',
        QrDataType.sms => '+218910461043',
      };
}
