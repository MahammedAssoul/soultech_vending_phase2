import 'package:soultech_vending/data/models/change_added_record.dart';
import 'package:soultech_vending/data/repositories/app_database.dart';

class ChangeAddedRepository {
  Future<List<ChangeAddedRecord>> getAll(
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
      'change_added_records',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(ChangeAddedRecord.fromMap).toList();
  }

  Future<int> save(ChangeAddedRecord record) async {
    final db = await AppDatabase.instance.db;
    if (record.id == null)
      return db.insert('change_added_records', record.toMap());
    await db.update('change_added_records', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
    return record.id!;
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.db;
    await db.delete('change_added_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalByMachine(int machineId,
      {DateTime? from, DateTime? to}) async {
    final db = await AppDatabase.instance.db;
    final conditions = ['machine_id = ?'];
    final args = <Object?>[machineId];
    if (from != null) {
      conditions.add("date >= ?");
      args.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      conditions.add("date <= ?");
      args.add(to.toIso8601String().split('T').first);
    }
    final r = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM change_added_records WHERE ${conditions.join(' AND ')}',
      args,
    );
    return (r.first['total'] as num?)?.toDouble() ?? 0;
  }
}
