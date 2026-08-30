import 'package:soultech_vending/data/models/spending_record.dart';
import 'package:soultech_vending/data/repositories/app_database.dart';

/// Persists business spending records and provides SUM/COUNT aggregations
/// for dashboards and reports.
class SpendingRepository {
  Future<List<SpendingRecord>> getAll({
    SpendingType? type,
    int? machineId,
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await AppDatabase.instance.db;
    final conditions = <String>[];
    final args = <Object?>[];
    if (type != null) {
      conditions.add('type = ?');
      args.add(type.dbValue);
    }
    if (machineId != null) {
      conditions.add('machine_id = ?');
      args.add(machineId);
    }
    if (from != null) {
      conditions.add('date >= ?');
      args.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      conditions.add('date <= ?');
      args.add(to.toIso8601String().split('T').first);
    }
    final rows = await db.query(
      'spending_records',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(SpendingRecord.fromMap).toList();
  }

  Future<SpendingRecord?> getById(int id) async {
    final db = await AppDatabase.instance.db;
    final rows =
        await db.query('spending_records', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return SpendingRecord.fromMap(rows.first);
  }

  Future<int> save(SpendingRecord record) async {
    final db = await AppDatabase.instance.db;
    if (record.id == null) {
      return db.insert('spending_records', record.toMap());
    }
    final updated = record.copyWith(updatedAt: DateTime.now());
    await db.update('spending_records', updated.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
    return record.id!;
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.db;
    await db.delete('spending_records', where: 'id = ?', whereArgs: [id]);
  }

  /// SUM(amount) grouped by nothing — the raw totals for the filter range.
  Future<Map<String, double>> getTotals({
    int? machineId,
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await AppDatabase.instance.db;
    final conditions = <String>[];
    final args = <Object?>[];
    if (machineId != null) {
      conditions.add('machine_id = ?');
      args.add(machineId);
    }
    if (from != null) {
      conditions.add('date >= ?');
      args.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      conditions.add('date <= ?');
      args.add(to.toIso8601String().split('T').first);
    }
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    final r = await db.rawQuery(
      '''SELECT
        COALESCE(SUM(CASE WHEN type = 'inventory' THEN amount ELSE 0 END), 0) as inventory_total,
        COALESCE(SUM(CASE WHEN type = 'utilities' THEN amount ELSE 0 END), 0) as utilities_total,
        COALESCE(SUM(amount), 0) as total
      FROM spending_records $where''',
      args.isEmpty ? null : args,
    );
    final row = r.first;
    return {
      'inventory_total': (row['inventory_total'] as num?)?.toDouble() ?? 0,
      'utilities_total': (row['utilities_total'] as num?)?.toDouble() ?? 0,
      'total': (row['total'] as num?)?.toDouble() ?? 0,
    };
  }

  /// Total spending between [from] (inclusive) and [to] (exclusive),
  /// using full date boundaries — e.g. first day of month → first day of
  /// next month. Prevents cross-year/month leakage.
  Future<Map<String, double>> getRangeTotals({
    int? machineId,
    required DateTime from,
    required DateTime to,
  }) =>
      getTotals(
          machineId: machineId,
          from: from,
          to: to.subtract(const Duration(days: 1)));

  /// Convenience: current-month totals.
  Future<Map<String, double>> getCurrentMonthTotals({int? machineId}) async {
    final now = DateTime.now();
    return getRangeTotals(
      machineId: machineId,
      from: DateTime(now.year, now.month, 1),
      to: DateTime(now.year, now.month + 1, 1),
    );
  }
}
