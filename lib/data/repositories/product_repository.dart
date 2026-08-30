import 'package:soultech_vending/data/models/product.dart';
import 'package:soultech_vending/data/repositories/app_database.dart';

class ProductRepository {
  Future<List<Product>> getAll({bool includeInactive = false}) async {
    final db = await AppDatabase.instance.db;
    final rows = includeInactive
        ? await db.query('products', orderBy: 'name ASC')
        : await db.query('products', where: 'active = 1', orderBy: 'name ASC');
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> getById(int id) async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<int> save(Product product) async {
    final db = await AppDatabase.instance.db;
    if (product.id == null) {
      return db.insert('products', product.toMap());
    }
    await db.update('products', product.toMap(),
        where: 'id = ?', whereArgs: [product.id]);
    return product.id!;
  }

  Future<void> deactivate(int id) async {
    final db = await AppDatabase.instance.db;
    await db.update('products', {'active': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.db;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> adjustStock(int productId, double delta) async {
    final db = await AppDatabase.instance.db;
    await db.rawUpdate(
      'UPDATE products SET current_stock = MAX(0, current_stock + ?) WHERE id = ?',
      [delta, productId],
    );
  }

  Future<List<Product>> getLowStock() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.rawQuery(
      'SELECT * FROM products WHERE active = 1 AND current_stock <= min_stock AND current_stock > 0 ORDER BY current_stock ASC',
    );
    return rows.map(Product.fromMap).toList();
  }

  Future<List<Product>> getOutOfStock() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.rawQuery(
      'SELECT * FROM products WHERE active = 1 AND current_stock = 0 ORDER BY name ASC',
    );
    return rows.map(Product.fromMap).toList();
  }

  /// Returns the quantity of [productId] stocked inside [machineId].
  Future<double> getMachineStock(int machineId, int productId) async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query(
      'machine_inventory',
      where: 'machine_id = ? AND product_id = ?',
      whereArgs: [machineId, productId],
    );
    if (rows.isEmpty) return 0;
    return (rows.first['quantity'] as num?)?.toDouble() ?? 0;
  }

  /// Returns the per-product stock summary for [machineId] (products with
  /// quantities loaded in that machine).
  Future<List<Map<String, Object?>>> getMachineInventory(int machineId) async {
    final db = await AppDatabase.instance.db;
    return db.rawQuery('''
      SELECT p.id as product_id, p.name, p.selling_price, p.cost_price, p.min_stock, p.active,
             COALESCE(mi.quantity, 0) as quantity
      FROM products p
      LEFT JOIN machine_inventory mi ON mi.product_id = p.id AND mi.machine_id = ?
      WHERE p.active = 1
      ORDER BY p.name ASC
    ''', [machineId]);
  }

  /// Counts products in a machine by status.
  Future<Map<String, int>> countMachineStockStatus(int machineId) async {
    final db = await AppDatabase.instance.db;
    final rows = await db.rawQuery('''
      SELECT
        SUM(CASE WHEN COALESCE(mi.quantity,0) = 0 THEN 1 ELSE 0 END) as out_of_stock,
        SUM(CASE WHEN COALESCE(mi.quantity,0) > 0 AND COALESCE(mi.quantity,0) <= p.min_stock THEN 1 ELSE 0 END) as low_stock,
        SUM(CASE WHEN COALESCE(mi.quantity,0) > p.min_stock THEN 1 ELSE 0 END) as in_stock
      FROM products p
      LEFT JOIN machine_inventory mi ON mi.product_id = p.id AND mi.machine_id = ?
      WHERE p.active = 1
    ''', [machineId]);
    final row = rows.first;
    return {
      'out_of_stock': (row['out_of_stock'] as num?)?.toInt() ?? 0,
      'low_stock': (row['low_stock'] as num?)?.toInt() ?? 0,
      'in_stock': (row['in_stock'] as num?)?.toInt() ?? 0,
    };
  }
}
