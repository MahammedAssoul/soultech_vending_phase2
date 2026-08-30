import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final instance = AppDatabase._();
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'soultech_vending.db');
    _db = await openDatabase(
      path,
      version: 4,
      onCreate: _create,
      onUpgrade: _upgrade,
    );
    return _db!;
  }

  Future<void> _create(Database db, int version) async {
    await _createV1(db);
    await _createV2(db);
    await _createV4(db);
  }

  Future<void> _createV1(Database db) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS machines(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      code TEXT NOT NULL UNIQUE,
      location TEXT NOT NULL,
      commission_percent REAL NOT NULL DEFAULT 0,
      active INTEGER NOT NULL DEFAULT 1,
      installed_at TEXT,
      notes TEXT DEFAULT ''
    )''');

    await db.execute('''CREATE TABLE IF NOT EXISTS products(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category TEXT NOT NULL DEFAULT '',
      selling_price REAL NOT NULL DEFAULT 0,
      cost_price REAL NOT NULL DEFAULT 0,
      low_stock_threshold INTEGER NOT NULL DEFAULT 5,
      current_stock INTEGER NOT NULL DEFAULT 0,
      min_stock INTEGER NOT NULL DEFAULT 5,
      active INTEGER NOT NULL DEFAULT 1,
      notes TEXT DEFAULT ''
    )''');
  }

  Future<void> _createV2(Database db) async {
    // Full sale records with product detail
    await db.execute('''CREATE TABLE IF NOT EXISTS sale_records(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      machine_id INTEGER NOT NULL,
      product_id INTEGER,
      product_name TEXT NOT NULL DEFAULT '',
      quantity REAL NOT NULL DEFAULT 1,
      unit_price REAL NOT NULL DEFAULT 0,
      total_amount REAL NOT NULL DEFAULT 0,
      cost_price REAL NOT NULL DEFAULT 0,
      total_cost REAL NOT NULL DEFAULT 0,
      profit REAL NOT NULL DEFAULT 0,
      date TEXT NOT NULL,
      time TEXT NOT NULL DEFAULT '',
      notes TEXT DEFAULT '',
      FOREIGN KEY(machine_id) REFERENCES machines(id)
    )''');

    // Restocking records
    await db.execute('''CREATE TABLE IF NOT EXISTS restocking_records(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      machine_id INTEGER NOT NULL,
      product_id INTEGER,
      product_name TEXT NOT NULL DEFAULT '',
      quantity REAL NOT NULL DEFAULT 0,
      unit_cost REAL NOT NULL DEFAULT 0,
      total_cost REAL NOT NULL DEFAULT 0,
      date TEXT NOT NULL,
      notes TEXT DEFAULT '',
      FOREIGN KEY(machine_id) REFERENCES machines(id)
    )''');

    // Change Added records
    await db.execute('''CREATE TABLE IF NOT EXISTS change_added_records(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      machine_id INTEGER NOT NULL,
      amount REAL NOT NULL DEFAULT 0,
      date TEXT NOT NULL,
      time TEXT NOT NULL DEFAULT '',
      notes TEXT DEFAULT '',
      FOREIGN KEY(machine_id) REFERENCES machines(id)
    )''');

    // Cash Reading records
    await db.execute('''CREATE TABLE IF NOT EXISTS cash_reading_records(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      machine_id INTEGER NOT NULL,
      reading_amount REAL NOT NULL DEFAULT 0,
      date TEXT NOT NULL,
      time TEXT NOT NULL DEFAULT '',
      notes TEXT DEFAULT '',
      FOREIGN KEY(machine_id) REFERENCES machines(id)
    )''');

    // Reconciliation records
    await db.execute('''CREATE TABLE IF NOT EXISTS reconciliation_records(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      machine_id INTEGER NOT NULL,
      expected_amount REAL NOT NULL DEFAULT 0,
      actual_amount REAL NOT NULL DEFAULT 0,
      difference REAL NOT NULL DEFAULT 0,
      date TEXT NOT NULL,
      notes TEXT DEFAULT '',
      FOREIGN KEY(machine_id) REFERENCES machines(id)
    )''');

    // Cash Collection records
    await db.execute('''CREATE TABLE IF NOT EXISTS cash_collection_records(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      machine_id INTEGER NOT NULL,
      collected_amount REAL NOT NULL DEFAULT 0,
      date TEXT NOT NULL,
      time TEXT NOT NULL DEFAULT '',
      notes TEXT DEFAULT '',
      FOREIGN KEY(machine_id) REFERENCES machines(id)
    )''');

    // Machine inventory (per-machine per-product stock)
    await db.execute('''CREATE TABLE IF NOT EXISTS machine_inventory(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      machine_id INTEGER NOT NULL,
      product_id INTEGER NOT NULL,
      quantity REAL NOT NULL DEFAULT 0,
      UNIQUE(machine_id, product_id),
      FOREIGN KEY(machine_id) REFERENCES machines(id),
      FOREIGN KEY(product_id) REFERENCES products(id)
    )''');
  }

  Future<void> _createV4(Database db) async {
    // Business spending records (inventory + utilities)
    await db.execute('''CREATE TABLE IF NOT EXISTS spending_records(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL,
      date TEXT NOT NULL,
      amount REAL NOT NULL DEFAULT 0,
      description TEXT DEFAULT '',
      machine_id INTEGER,
      supplier TEXT DEFAULT '',
      utility_type TEXT DEFAULT '',
      reference_number TEXT DEFAULT '',
      notes TEXT DEFAULT '',
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY(machine_id) REFERENCES machines(id)
    )''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_spending_date ON spending_records(date)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_spending_type ON spending_records(type)');
  }

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migrate old sales data into sale_records
      await db.execute('''CREATE TABLE IF NOT EXISTS sale_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        machine_id INTEGER NOT NULL,
        product_id INTEGER,
        product_name TEXT NOT NULL DEFAULT '',
        quantity REAL NOT NULL DEFAULT 1,
        unit_price REAL NOT NULL DEFAULT 0,
        total_amount REAL NOT NULL DEFAULT 0,
        cost_price REAL NOT NULL DEFAULT 0,
        total_cost REAL NOT NULL DEFAULT 0,
        profit REAL NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        time TEXT NOT NULL DEFAULT '',
        notes TEXT DEFAULT '',
        FOREIGN KEY(machine_id) REFERENCES machines(id)
      )''');

      // Migrate old sales if the table exists
      try {
        final oldSales = await db.query('sales');
        for (final row in oldSales) {
          final amount = (row['amount'] as num?)?.toDouble() ?? 0;
          final cost = (row['cost'] as num?)?.toDouble() ?? 0;
          await db.insert('sale_records', {
            'machine_id': row['machine_id'],
            'total_amount': amount,
            'total_cost': cost,
            'profit': amount - cost,
            'date': row['date'] ?? DateTime.now().toIso8601String(),
            'notes': row['note'] ?? '',
          });
        }
      } catch (_) {
        // old sales table may not exist in fresh installs
      }

      // Add notes column to machines if not present
      try {
        await db
            .execute('ALTER TABLE machines ADD COLUMN notes TEXT DEFAULT ""');
      } catch (_) {}

      // Add new columns to products
      try {
        await db.execute(
            'ALTER TABLE products ADD COLUMN current_stock INTEGER NOT NULL DEFAULT 0');
      } catch (_) {}
      try {
        await db.execute(
            'ALTER TABLE products ADD COLUMN min_stock INTEGER NOT NULL DEFAULT 5');
      } catch (_) {}
      try {
        await db.execute(
            'ALTER TABLE products ADD COLUMN active INTEGER NOT NULL DEFAULT 1');
      } catch (_) {}
      try {
        await db
            .execute('ALTER TABLE products ADD COLUMN notes TEXT DEFAULT ""');
      } catch (_) {}
      try {
        await db.execute(
            'ALTER TABLE products ADD COLUMN category TEXT NOT NULL DEFAULT ""');
      } catch (_) {}

      await _createV2(db);
    }
    if (oldVersion < 3) {
      // Cash collection records (Phase 2.1)
      await db.execute('''CREATE TABLE IF NOT EXISTS cash_collection_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        machine_id INTEGER NOT NULL,
        collected_amount REAL NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        time TEXT NOT NULL DEFAULT '',
        notes TEXT DEFAULT '',
        FOREIGN KEY(machine_id) REFERENCES machines(id)
      )''');
    }
    if (oldVersion < 4) {
      // Business spending records (inventory + utilities)
      await db.execute('''CREATE TABLE IF NOT EXISTS spending_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        description TEXT DEFAULT '',
        machine_id INTEGER,
        supplier TEXT DEFAULT '',
        utility_type TEXT DEFAULT '',
        reference_number TEXT DEFAULT '',
        notes TEXT DEFAULT '',
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(machine_id) REFERENCES machines(id)
      )''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_spending_date ON spending_records(date)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_spending_type ON spending_records(type)');
    }
  }
}
