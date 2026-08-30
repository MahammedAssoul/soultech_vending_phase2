import 'package:soultech_vending/data/models/reconciliation_record.dart';
import 'package:soultech_vending/data/repositories/app_database.dart';

class ReconciliationRepository {
  Future<List<ReconciliationRecord>> getAll(
      {int? machineId, DateTime? from, DateTime? to}) async {
    final db = await AppDatabase.instance.db;
    final conditions = <String>[];
    final args = <Object?>[];
    if (machineId != null) {
      conditions.add('machine_id = ?');
      args.add(machineId);
    }
    if (from != null) {
      conditions.add("date >= ?");
      args.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      conditions.add("date <= ?");
      args.add(to.toIso8601String().split('T').first);
    }
    final rows = await db.query(
      'reconciliation_records',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(ReconciliationRecord.fromMap).toList();
  }

  Future<int> save(ReconciliationRecord record) async {
    final db = await AppDatabase.instance.db;
    if (record.id == null)
      return db.insert('reconciliation_records', record.toMap());
    await db.update('reconciliation_records', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
    return record.id!;
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.db;
    await db.delete('reconciliation_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> getCashSummaryByMachine(
      {DateTime? from, DateTime? to}) async {
    final db = await AppDatabase.instance.db;
    final conditions = <String>[];
    final args = <Object?>[];
    if (from != null) {
      conditions.add("r.date >= ?");
      args.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      conditions.add("r.date <= ?");
      args.add(to.toIso8601String().split('T').first);
    }
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    return db.rawQuery('''
      SELECT m.name as machine_name, m.location,
        COALESCE(SUM(r.expected_amount), 0) as expected,
        COALESCE(SUM(r.actual_amount), 0) as actual,
        COALESCE(SUM(r.difference), 0) as difference
      FROM machines m
      LEFT JOIN reconciliation_records r ON r.machine_id = m.id $where
      GROUP BY m.id ORDER BY m.name ASC
    ''', args.isEmpty ? null : args);
  }
}
