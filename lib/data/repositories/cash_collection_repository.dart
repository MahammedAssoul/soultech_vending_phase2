import 'package:soultech_vending/data/models/cash_collection_record.dart';
import 'package:soultech_vending/data/repositories/app_database.dart';

class CashCollectionRepository {
  Future<List<CashCollectionRecord>> getAll({
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
    final rows = await db.query(
      'cash_collection_records',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(CashCollectionRecord.fromMap).toList();
  }

  Future<CashCollectionRecord?> getById(int id) async {
    final db = await AppDatabase.instance.db;
    final rows = await db
        .query('cash_collection_records', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return CashCollectionRecord.fromMap(rows.first);
  }

  Future<int> save(CashCollectionRecord record) async {
    final db = await AppDatabase.instance.db;
    if (record.id == null) {
      return db.insert('cash_collection_records', record.toMap());
    }
    await db.update('cash_collection_records', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
    return record.id!;
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.db;
    await db
        .delete('cash_collection_records', where: 'id = ?', whereArgs: [id]);
  }

  /// Total cash collected within the date range (optionally per machine).
  Future<double> getTotal(
      {int? machineId, DateTime? from, DateTime? to}) async {
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
      'SELECT COALESCE(SUM(collected_amount), 0) as total FROM cash_collection_records $where',
      args.isEmpty ? null : args,
    );
    return (r.first['total'] as num?)?.toDouble() ?? 0;
  }

  /// Count of collections within a machine range (per machine), for reports.
  Future<List<Map<String, Object?>>> getCollectionsByMachine({
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await AppDatabase.instance.db;
    final conditions = <String>[];
    final args = <Object?>[];
    if (from != null) {
      conditions.add('c.date >= ?');
      args.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      conditions.add('c.date <= ?');
      args.add(to.toIso8601String().split('T').first);
    }
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    return db.rawQuery('''
      SELECT m.id as machine_id, m.name as machine_name,
        COUNT(c.id) as collection_count,
        COALESCE(SUM(c.collected_amount), 0) as total_collected
      FROM machines m
      LEFT JOIN cash_collection_records c ON c.machine_id = m.id $where
      GROUP BY m.id ORDER BY total_collected DESC
    ''', args.isEmpty ? null : args);
  }

  /// Daily collected totals within [from]–[to], grouped by date.
  Future<List<Map<String, Object?>>> getCollectionsByDay({
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
    return db.rawQuery('''
      SELECT date, SUM(collected_amount) as daily_collected, COUNT(*) as collections
      FROM cash_collection_records $where
      GROUP BY date ORDER BY date ASC
    ''', args.isEmpty ? null : args);
  }
}
