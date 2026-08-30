import 'package:soultech_vending/data/models/sale_record.dart';
import 'package:soultech_vending/data/repositories/app_database.dart';

class SaleRepository {
  Future<List<SaleRecord>> getAll({
    int? machineId,
    DateTime? from,
    DateTime? to,
    int? productId,
  }) async {
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
    if (productId != null) {
      conditions.add('product_id = ?');
      args.add(productId);
    }

    final where = conditions.isEmpty ? null : conditions.join(' AND ');
    final rows = await db.query(
      'sale_records',
      where: where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(SaleRecord.fromMap).toList();
  }

  Future<SaleRecord?> getById(int id) async {
    final db = await AppDatabase.instance.db;
    final rows =
        await db.query('sale_records', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return SaleRecord.fromMap(rows.first);
  }

  Future<int> save(SaleRecord record) async {
    final db = await AppDatabase.instance.db;
    if (record.id == null) {
      return db.insert('sale_records', record.toMap());
    }
    await db.update('sale_records', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
    return record.id!;
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.db;
    await db.delete('sale_records', where: 'id = ?', whereArgs: [id]);
  }

  // ── Aggregation queries ──────────────────────────────────────────────────

  Future<Map<String, double>> getSummary({
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
      conditions.add("date >= ?");
      args.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      conditions.add("date <= ?");
      args.add(to.toIso8601String().split('T').first);
    }
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';

    final r = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(total_amount), 0) as total_sales,
        COALESCE(SUM(total_cost), 0) as total_cost,
        COALESCE(SUM(profit), 0) as total_profit,
        COUNT(*) as transaction_count
      FROM sale_records
      $where
    ''', args.isEmpty ? null : args);

    final row = r.first;
    return {
      'total_sales': (row['total_sales'] as num?)?.toDouble() ?? 0,
      'total_cost': (row['total_cost'] as num?)?.toDouble() ?? 0,
      'total_profit': (row['total_profit'] as num?)?.toDouble() ?? 0,
      'transaction_count': (row['transaction_count'] as num?)?.toDouble() ?? 0,
    };
  }

  Future<List<Map<String, Object?>>> getSalesByDay({
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
      conditions.add("date >= ?");
      args.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      conditions.add("date <= ?");
      args.add(to.toIso8601String().split('T').first);
    }
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    return db.rawQuery('''
      SELECT date, SUM(total_amount) as daily_sales, SUM(profit) as daily_profit
      FROM sale_records $where
      GROUP BY date ORDER BY date ASC
    ''', args.isEmpty ? null : args);
  }

  Future<List<Map<String, Object?>>> getSalesByMachine({
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await AppDatabase.instance.db;
    final conditions = <String>[];
    final args = <Object?>[];
    if (from != null) {
      conditions.add("s.date >= ?");
      args.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      conditions.add("s.date <= ?");
      args.add(to.toIso8601String().split('T').first);
    }
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    return db.rawQuery('''
      SELECT m.id as machine_id, m.name as machine_name, m.location, m.commission_percent,
        COALESCE(SUM(s.total_amount), 0) as total_sales,
        COALESCE(SUM(s.total_cost), 0) as total_cost,
        COALESCE(SUM(s.profit), 0) as gross_profit,
        COUNT(s.id) as transactions
      FROM machines m
      LEFT JOIN sale_records s ON s.machine_id = m.id $where
      GROUP BY m.id ORDER BY total_sales DESC
    ''', args.isEmpty ? null : args);
  }

  Future<List<Map<String, Object?>>> getSalesByProduct({
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
      conditions.add("date >= ?");
      args.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      conditions.add("date <= ?");
      args.add(to.toIso8601String().split('T').first);
    }
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    return db.rawQuery('''
      SELECT product_name,
        SUM(quantity) as total_qty,
        SUM(total_amount) as revenue,
        SUM(total_cost) as cost,
        SUM(profit) as profit
      FROM sale_records $where
      GROUP BY product_name ORDER BY revenue DESC
    ''', args.isEmpty ? null : args);
  }

  /// Sales grouped by month (YYYY-MM) for charts and month-to-month trends.
  Future<List<Map<String, Object?>>> getSalesByMonth({
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
      conditions.add("date >= ?");
      args.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      conditions.add("date <= ?");
      args.add(to.toIso8601String().split('T').first);
    }
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    return db.rawQuery('''
      SELECT substr(date, 1, 7) as month,
             SUM(total_amount) as total_sales,
             SUM(profit) as total_profit
      FROM sale_records $where
      GROUP BY month ORDER BY month ASC
    ''', args.isEmpty ? null : args);
  }

  /// Commission per machine: sales * machine.commission_percent / 100.
  Future<List<Map<String, Object?>>> getCommissionByMachine({
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await AppDatabase.instance.db;
    final conditions = <String>[];
    final args = <Object?>[];
    if (from != null) {
      conditions.add("s.date >= ?");
      args.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      conditions.add("s.date <= ?");
      args.add(to.toIso8601String().split('T').first);
    }
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    return db.rawQuery('''
      SELECT m.id as machine_id, m.name as machine_name, m.location, m.commission_percent,
        COALESCE(SUM(s.total_amount), 0) as total_sales,
        COALESCE(SUM(s.total_amount), 0) * m.commission_percent / 100.0 as commission
      FROM machines m
      LEFT JOIN sale_records s ON s.machine_id = m.id $where
      GROUP BY m.id ORDER BY m.name ASC
    ''', args.isEmpty ? null : args);
  }

  /// Total commission within the date range.
  Future<double> getTotalCommission(
      {int? machineId, DateTime? from, DateTime? to}) async {
    final db = await AppDatabase.instance.db;
    final conditions = <String>[];
    final args = <Object?>[];
    if (machineId != null) {
      conditions.add('s.machine_id = ?');
      args.add(machineId);
    }
    if (from != null) {
      conditions.add("s.date >= ?");
      args.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      conditions.add("s.date <= ?");
      args.add(to.toIso8601String().split('T').first);
    }
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    final r = await db.rawQuery('''
      SELECT COALESCE(SUM(s.total_amount * m.commission_percent / 100.0), 0) as total
      FROM sale_records s JOIN machines m ON m.id = s.machine_id $where
    ''', args.isEmpty ? null : args);
    return (r.first['total'] as num?)?.toDouble() ?? 0;
  }

  /// Total receipt-style commission within the date range.
  ///
  /// Matches the per-machine commission shown on the monthly sales receipt:
  /// (cash collected − change added) × machine.commission_percent / 100.
  Future<double> getTotalCommissionByMachine({
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await AppDatabase.instance.db;
    final collConditions = <String>[];
    final collArgs = <Object?>[];
    final changeConditions = <String>[];
    final changeArgs = <Object?>[];
    if (from != null) {
      collConditions.add('c.date >= ?');
      collArgs.add(from.toIso8601String().split('T').first);
      changeConditions.add('ch.date >= ?');
      changeArgs.add(from.toIso8601String().split('T').first);
    }
    if (to != null) {
      collConditions.add('c.date <= ?');
      collArgs.add(to.toIso8601String().split('T').first);
      changeConditions.add('ch.date <= ?');
      changeArgs.add(to.toIso8601String().split('T').first);
    }
    final collWhere =
        collConditions.isEmpty ? '' : 'WHERE ${collConditions.join(' AND ')}';
    final changeWhere = changeConditions.isEmpty
        ? ''
        : 'WHERE ${changeConditions.join(' AND ')}';
    final r = await db.rawQuery('''
      SELECT COALESCE(SUM(
        (COALESCE(c.collected, 0) - COALESCE(ch.change, 0)) * m.commission_percent / 100.0
      ), 0) as total
      FROM machines m
      LEFT JOIN (
        SELECT c.machine_id, SUM(c.collected_amount) as collected
        FROM cash_collection_records c $collWhere
        GROUP BY c.machine_id
      ) c ON c.machine_id = m.id
      LEFT JOIN (
        SELECT ch.machine_id, SUM(ch.amount) as change
        FROM change_added_records ch $changeWhere
        GROUP BY ch.machine_id
      ) ch ON ch.machine_id = m.id
    ''', [...collArgs, ...changeArgs]);
    return (r.first['total'] as num?)?.toDouble() ?? 0;
  }
}
