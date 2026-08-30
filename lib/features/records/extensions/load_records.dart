part of '../records_page.dart';

/// Query-builder helpers for the records page (kept as an extension so the
/// State class stays readable).
extension _LoadRecords on _RecordsPageState {
  String? _whereClause(String machineCol, String dateCol) {
    final conditions = <String>[];
    if (_machineId != null) conditions.add('$machineCol = ?');
    if (_from != null) conditions.add('$dateCol >= ?');
    if (_to != null) conditions.add('$dateCol <= ?');
    if (_type != 'all' && _type != RecordType.sale.name) {
      return null; // sales handled separately
    }
    return conditions.isEmpty ? null : conditions.join(' AND ');
  }

  List<Object?>? _args(String machineCol, String dateCol) {
    final a = <Object?>[];
    if (_machineId != null) a.add(_machineId);
    if (_from != null) a.add(_from!.toIso8601String().split('T').first);
    if (_to != null) a.add(_to!.toIso8601String().split('T').first);
    return a.isEmpty ? null : a;
  }
}
