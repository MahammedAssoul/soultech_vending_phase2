import 'package:soultech_vending/data/models/cash_reading_record.dart';
import 'package:soultech_vending/data/repositories/app_database.dart';

class CashReadingRepository {
  Future<List<CashReadingRecord>> getAll(
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
      'cash_reading_records',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(CashReadingRecord.fromMap).toList();
  }

  Future<int> save(CashReadingRecord record) async {
    final db = await AppDatabase.instance.db;
    if (record.id == null)
      return db.insert('cash_reading_records', record.toMap());
    await db.update('cash_reading_records', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
    return record.id!;
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.db;
    await db.delete('cash_reading_records', where: 'id = ?', whereArgs: [id]);
  }
}
