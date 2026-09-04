import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soultech_vending/data/repositories/app_database.dart';

/// Exports and restores the full database as CSV files (zipped).
///
/// Includes all operational tables (machines, products, sales, restocking,
/// change added, cash reading, reconciliation, machine inventory, spending).
/// Each table is exported as its own CSV file inside a single `.zip` so the
/// backup can be transferred to another phone and restored there.
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
    'spending_records',
  ];

  /// Exports all tables to CSV files, zips them, and shares the zip.
  static Future<void> exportBackup() async {
    final db = await AppDatabase.instance.db;
    final archive = Archive();

    for (final table in _tables) {
      final rows = await db.query(table);
      final csv = _rowsToCsv(rows);
      archive.addFile(ArchiveFile.string('$table.csv', csv));
    }

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) {
      throw StateError('Failed to encode backup archive');
    }

    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final file = File(
        '${dir.path}/soultech_backup_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}.zip');
    await file.writeAsBytes(zipBytes);
    await Share.shareXFiles([XFile(file.path, mimeType: 'application/zip')]);
  }

  /// Restores the database from a CSV zip backup. Replaces all data.
  static Future<void> restoreBackup(String filePath) async {
    final db = await AppDatabase.instance.db;
    final bytes = await File(filePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final data = <String, List<Map<String, Object?>>>{};
    for (final file in archive.files) {
      if (!file.isFile) continue;
      final name = file.name;
      if (!name.endsWith('.csv')) continue;
      final table = name.substring(0, name.length - 4);
      final content = utf8.decode(file.content as List<int>);
      data[table] = _csvToRows(content);
    }

    // Wrap in a transaction so a failure rolls back cleanly.
    await db.transaction((txn) async {
      // Clear existing data (respecting FK order).
      for (final table in _tables.reversed) {
        await txn.delete(table);
      }
      // Insert backup rows.
      for (final table in _tables) {
        final rows = data[table] ?? [];
        for (final row in rows) {
          await txn.insert(table, row);
        }
      }
    });
  }

  // ── CSV helpers ──────────────────────────────────────────────────────────

  /// Serializes rows to CSV with a header row (column names from the first
  /// row's keys). Values are escaped per RFC 4180.
  static String _rowsToCsv(List<Map<String, Object?>> rows) {
    if (rows.isEmpty) return '';
    final columns = rows.first.keys.toList();
    final buf = StringBuffer();
    buf.writeln(columns.map(_escape).join(','));
    for (final row in rows) {
      buf.writeln(columns.map((c) => _escape('${row[c] ?? ''}')).join(','));
    }
    return buf.toString();
  }

  /// Parses CSV content (with header row) into rows keyed by column name.
  /// Values are kept as strings; [restoreBackup] coerces them to the correct
  /// SQLite types when inserting.
  static List<Map<String, Object?>> _csvToRows(String content) {
    final lines = const LineSplitter().convert(content);
    if (lines.isEmpty) return [];
    final header = _parseLine(lines.first);
    final rows = <Map<String, Object?>>[];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final cols = _parseLine(line);
      final row = <String, Object?>{};
      for (var c = 0; c < header.length; c++) {
        row[header[c]] = c < cols.length ? cols[c] : '';
      }
      rows.add(row);
    }
    return rows;
  }

  /// Escapes a field for CSV output (quotes fields containing commas, quotes,
  /// or newlines; doubles embedded quotes).
  static String _escape(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Simple CSV line parser (handles quoted fields).
  static List<String> _parseLine(String line) {
    final result = <String>[];
    final buf = StringBuffer();
    bool inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (c == ',' && !inQuotes) {
        result.add(buf.toString());
        buf.clear();
      } else {
        buf.write(c);
      }
    }
    result.add(buf.toString());
    return result;
  }
}
