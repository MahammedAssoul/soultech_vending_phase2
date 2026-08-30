import 'dart:io';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/models/sale_record.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';
import 'package:soultech_vending/data/repositories/sale_repository.dart';

/// Result of a CSV import.
class CsvImportResult {
  const CsvImportResult({
    required this.imported,
    required this.skipped,
    required this.errors,
    required this.errorMessages,
  });

  final int imported;
  final int skipped;
  final int errors;
  final List<String> errorMessages;

  bool get hasErrors => errors > 0 || errorMessages.isNotEmpty;
}

/// Imports historical sales from a CSV file.
///
/// Expected columns (header row):
///   date, machine, product, quantity, unitPrice, costPrice, notes
///
/// - `machine` may be a machine name or code.
/// - Rows are validated; invalid rows are reported and skipped.
/// - Duplicate rows (same date+machine+product+quantity+unitPrice) are skipped
///   to prevent accidental double imports.
class CsvImportService {
  const CsvImportService._();

  static Future<CsvImportResult> importSales(String filePath) async {
    final file = File(filePath);
    final lines = await file.readAsLines();
    if (lines.isEmpty) {
      return const CsvImportResult(
          imported: 0, skipped: 0, errors: 1, errorMessages: ['Empty file']);
    }

    final machines = await MachineRepository().getAll();
    final saleRepo = SaleRepository();

    int imported = 0;
    int skipped = 0;
    int errors = 0;
    final errorMessages = <String>[];
    final seen = <String>{};

    // Parse header (first line).
    final header = _parseLine(lines.first);
    final colIndex = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      colIndex[header[i].trim().toLowerCase()] = i;
    }

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final cols = _parseLine(line);

      String? cell(String name) {
        final idx = colIndex[name];
        if (idx == null || idx >= cols.length) return null;
        return cols[idx].trim();
      }

      final dateStr = cell('date');
      final machineRef = cell('machine') ?? cell('machine_code');
      final product = cell('product') ?? cell('product_name') ?? '';
      final qtyStr = cell('quantity') ?? cell('qty');
      final unitPriceStr =
          cell('unitPrice') ?? cell('unit_price') ?? cell('price');
      final costStr = cell('costPrice') ?? cell('cost_price') ?? cell('cost');
      final notes = cell('notes') ?? cell('note') ?? '';

      // Validate date
      final date = DateTime.tryParse(dateStr ?? '');
      if (date == null) {
        errors++;
        errorMessages.add('Row ${i + 1}: invalid date "$dateStr"');
        continue;
      }

      // Validate machine
      final machine = _findMachine(machines, machineRef ?? '');
      if (machine == null) {
        errors++;
        errorMessages.add('Row ${i + 1}: unknown machine "$machineRef"');
        continue;
      }

      // Validate quantity
      final qty = double.tryParse(qtyStr ?? '');
      if (qty == null || qty <= 0) {
        errors++;
        errorMessages.add('Row ${i + 1}: invalid quantity "$qtyStr"');
        continue;
      }

      // Validate prices
      final unitPrice = double.tryParse(unitPriceStr ?? '') ?? 0;
      final costPrice = double.tryParse(costStr ?? '') ?? 0;
      if (unitPrice < 0 || costPrice < 0) {
        errors++;
        errorMessages.add('Row ${i + 1}: negative price');
        continue;
      }

      // Dedup key
      final key =
          '${date.toIso8601String().split('T').first}|${machine.id}|$product|$qty|$unitPrice';
      if (seen.contains(key)) {
        skipped++;
        continue;
      }
      seen.add(key);

      final record = SaleRecord.calculated(
        machineId: machine.id!,
        productName: product,
        quantity: qty,
        unitPrice: unitPrice,
        costPrice: costPrice,
        date: date,
        notes: notes,
      );
      await saleRepo.save(record);
      imported++;
    }

    return CsvImportResult(
      imported: imported,
      skipped: skipped,
      errors: errors,
      errorMessages: errorMessages,
    );
  }

  static Machine? _findMachine(List<Machine> machines, String ref) {
    final r = ref.trim().toLowerCase();
    if (r.isEmpty) return null;
    for (final m in machines) {
      if (m.name.toLowerCase() == r || m.code.toLowerCase() == r) return m;
    }
    return null;
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
