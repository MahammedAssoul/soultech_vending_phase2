import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/repositories/app_database.dart';

class MachineRepository {
  Future<List<Machine>> getAll() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('machines', orderBy: 'name ASC');
    return rows.map(Machine.fromMap).toList();
  }

  Future<List<Machine>> getActive() async {
    final db = await AppDatabase.instance.db;
    final rows =
        await db.query('machines', where: 'active = 1', orderBy: 'name ASC');
    return rows.map(Machine.fromMap).toList();
  }

  Future<Machine?> getById(int id) async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('machines', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Machine.fromMap(rows.first);
  }

  Future<int> save(Machine machine) async {
    final db = await AppDatabase.instance.db;
    if (machine.id == null) {
      return db.insert('machines', machine.toMap());
    }
    await db.update('machines', machine.toMap(),
        where: 'id = ?', whereArgs: [machine.id]);
    return machine.id!;
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.db;
    return db.delete('machines', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countAll() async {
    final db = await AppDatabase.instance.db;
    final r = await db.rawQuery('SELECT COUNT(*) as c FROM machines');
    return (r.first['c'] as int?) ?? 0;
  }

  Future<int> countActive() async {
    final db = await AppDatabase.instance.db;
    final r = await db
        .rawQuery('SELECT COUNT(*) as c FROM machines WHERE active = 1');
    return (r.first['c'] as int?) ?? 0;
  }
}
