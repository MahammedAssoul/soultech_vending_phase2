import 'package:soultech_vending/core/localization/app_strings.dart';

/// The supported QR data types.
///
/// Adding a new type is a one-file change: add a value here, extend
/// [QrTypeInfo] for the builder/validator and add the user-facing labels,
/// then register the type in the creator screen's selector.
enum QrDataType {
  webUrl,
  phone,
  text,
  email,
  sms,
}

/// User-facing metadata for a [QrDataType].
class QrTypeInfo {
  const QrTypeInfo(this.type, this.l10nKey);

  final QrDataType type;

  /// Localization key used with [AppLang.tr].
  final String l10nKey;

  String get label => AppLang.tr(l10nKey);
}

/// Metadata registry — makes it easy to add new data types later
/// (WhatsApp, Wi-Fi, vCard, Location, Calendar, UPI, social links…).
class QrTypes {
  const QrTypes._();

  static const all = <QrTypeInfo>[
    QrTypeInfo(QrDataType.webUrl, L.webUrl),
    QrTypeInfo(QrDataType.phone, L.phoneNumber),
    QrTypeInfo(QrDataType.text, L.text),
    QrTypeInfo(QrDataType.email, L.email),
    QrTypeInfo(QrDataType.sms, L.sms),
  ];

  static QrTypeInfo infoOf(QrDataType type) =>
      all.firstWhere((t) => t.type == type, orElse: () => all.first);

  static String localize(QrDataType type) => infoOf(type).label;
}
