import 'package:soultech_vending/data/models/restocking_record.dart';
import 'package:soultech_vending/data/repositories/app_database.dart';
import 'package:soultech_vending/data/repositories/product_repository.dart';

class RestockingRepository {
  final _productRepo = ProductRepository();

  Future<List<RestockingRecord>> getAll(
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
      'restocking_records',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(RestockingRecord.fromMap).toList();
  }

  Future<RestockingRecord?> getById(int id) async {
    final db = await AppDatabase.instance.db;
    final rows =
        await db.query('restocking_records', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return RestockingRecord.fromMap(rows.first);
  }

  Future<int> save(RestockingRecord record,
      {RestockingRecord? previous}) async {
    final db = await AppDatabase.instance.db;
    int id;
    if (record.id == null) {
      id = await db.insert('restocking_records', record.toMap());
      // Increase product stock
      if (record.productId != null) {
        await _productRepo.adjustStock(record.productId!, record.quantity);
        await _addMachineStock(
            record.machineId, record.productId!, record.quantity);
      }
    } else {
      await db.update('restocking_records', record.toMap(),
          where: 'id = ?', whereArgs: [record.id]);
      id = record.id!;
      // Reverse the previous record's effect, then apply the new one.
      if (previous != null) {
        if (previous.productId != null) {
          await _productRepo.adjustStock(
              previous.productId!, -previous.quantity);
          await _addMachineStock(
              record.machineId, previous.productId!, -previous.quantity);
        }
        // If the record used to reference an old product, adjust that product.
        if (previous.productId != null &&
            previous.productId != record.productId) {
          // stock already reversed above via previous.productId.
        }
      }
      if (record.productId != null) {
        await _productRepo.adjustStock(record.productId!, record.quantity);
        await _addMachineStock(
            record.machineId, record.productId!, record.quantity);
      }
    }
    return id;
  }

  /// Adjusts the per-machine inventory for [productId] by [delta].
  Future<void> _addMachineStock(
      int machineId, int productId, double delta) async {
    final db = await AppDatabase.instance.db;
    final existing = await db.query(
      'machine_inventory',
      where: 'machine_id = ? AND product_id = ?',
      whereArgs: [machineId, productId],
    );
    if (existing.isEmpty) {
      if (delta > 0) {
        await db.insert('machine_inventory', {
          'machine_id': machineId,
          'product_id': productId,
          'quantity': delta
        });
      }
    } else {
      final current = (existing.first['quantity'] as num?)?.toDouble() ?? 0;
      final updated = (current + delta).clamp(0, double.infinity);
      await db.update(
        'machine_inventory',
        {'quantity': updated},
        where: 'machine_id = ? AND product_id = ?',
        whereArgs: [machineId, productId],
      );
    }
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.db;
    // Get record first to reverse stock
    final rows =
        await db.query('restocking_records', where: 'id = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      final record = RestockingRecord.fromMap(rows.first);
      if (record.productId != null) {
        await _productRepo.adjustStock(record.productId!, -record.quantity);
        await _addMachineStock(
            record.machineId, record.productId!, -record.quantity);
      }
    }
    await db.delete('restocking_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, double>> getSummary(
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
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    final r = await db.rawQuery(
      'SELECT COALESCE(SUM(total_cost), 0) as total_cost, COALESCE(SUM(quantity), 0) as total_qty FROM restocking_records $where',
      args.isEmpty ? null : args,
    );
    return {
      'total_cost': (r.first['total_cost'] as num?)?.toDouble() ?? 0,
      'total_qty': (r.first['total_qty'] as num?)?.toDouble() ?? 0,
    };
  }
}
