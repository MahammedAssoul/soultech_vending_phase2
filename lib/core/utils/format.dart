import 'package:intl/intl.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';

/// Formatting helpers for currency, numbers and dates.
class Fmt {
  const Fmt._();

  static final _money = NumberFormat('#,##0.0');

  static final _num = NumberFormat('#,##0.##');

  static String money(num? v) =>
      '${AppLang.tr('currency')} ${_money.format(v ?? 0)}';

  static String number(num? v) => _num.format(v ?? 0);

  static String date(DateTime? d) =>
      d == null ? '' : DateFormat('dd/MM/yyyy').format(d);

  static String dateTime(DateTime? d) =>
      d == null ? '' : DateFormat('dd/MM/yyyy HH:mm').format(d);
}
