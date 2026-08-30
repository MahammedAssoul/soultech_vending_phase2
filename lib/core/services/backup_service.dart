import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soultech_vending/data/repositories/app_database.dart';

/// Exports and restores the full database as a JSON backup file.
///
/// Includes all operational tables (machines, products, sales, restocking,
/// change added, cash reading, reconciliation, machine inventory). No
/// passwords/secrets are stored.
class BackupService {
  const BackupService._();

  static const _tables = [
    'machines',
    'products',
    'sale_records',
    'restocking_records',
    'change_added_records',
    'cash_reading_records',
    'cash_collection_records',
    'reconciliation_records',
    'machine_inventory',
  ];

  /// Exports all tables to a JSON file and shares it.
  static Future<void> exportBackup() async {
    final db = await AppDatabase.instance.db;
    final data = <String, List<Map<String, Object?>>>{};
    for (final table in _tables) {
      final rows = await db.query(table);
      data[table] = rows;
    }
    final json = jsonEncode({
      'app': 'soultech_vending',
      'version': 2,
      'exported_at': DateTime.now().toIso8601String(),
      'data': data,
    });

    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final file = File(
        '${dir.path}/soultech_backup_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}.json');
    await file.writeAsString(json);
    await Share.shareXFiles([XFile(file.path, mimeType: 'application/json')]);
  }

  /// Restores the database from a JSON backup file. Replaces all data.
  static Future<void> restoreBackup(String filePath) async {
    final db = await AppDatabase.instance.db;
    final file = File(filePath);
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final data = (json['data'] as Map<String, dynamic>?) ?? {};

    // Wrap in a transaction so a failure rolls back cleanly.
    await db.transaction((txn) async {
      // Clear existing data (respecting FK order).
      for (final table in _tables.reversed) {
        await txn.delete(table);
      }
      // Insert backup rows.
      for (final table in _tables) {
        final rows = (data[table] as List<dynamic>?) ?? [];
        for (final row in rows) {
          await txn.insert(table, (row as Map).cast<String, Object?>());
        }
      }
    });
  }
}
