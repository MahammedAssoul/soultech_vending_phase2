import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/utils/format.dart';
import 'package:soultech_vending/data/models/spending_record.dart';
import 'package:soultech_vending/features/reports/report_service.dart';

/// Generates a multi-sheet Excel workbook for the current report period.
class ExcelReportService {
  const ExcelReportService._();

  static Future<Uint8List> generate(ReportData data) async {
    final excel = Excel.createExcel();
    excel.setDefaultSheet('Summary');

    Sheet sheet(String name) => excel[name];

    void writeRow(Sheet s, int row, List<String> values,
        {bool header = false}) {
      for (var c = 0; c < values.length; c++) {
        final cell =
            s.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row));
        cell.value = TextCellValue(values[c]);
        if (header) {
          cell.cellStyle = CellStyle(
            bold: true,
            backgroundColorHex: '123C73'.excelColor,
            fontColorHex: 'FFFFFF'.excelColor,
          );
        }
      }
    }

    // ── Summary sheet ──
    writeRow(
        sheet('Summary'),
        0,
        [
          AppLang.tr('summary'),
          '',
          '',
          '',
        ],
        header: true);
    writeRow(sheet('Summary'), 1,
        [AppLang.tr('totalSales'), Fmt.money(data.totalSales)]);
    writeRow(sheet('Summary'), 2,
        [AppLang.tr('totalCost'), Fmt.money(data.totalCost)]);
    writeRow(sheet('Summary'), 3,
        [AppLang.tr('grossProfit'), Fmt.money(data.grossProfit)]);
    writeRow(sheet('Summary'), 4,
        [AppLang.tr('totalCommission'), Fmt.money(data.totalCommission)]);
    writeRow(sheet('Summary'), 5,
        [AppLang.tr('netProfit'), Fmt.money(data.netProfit)]);
    writeRow(sheet('Summary'), 6,
        [AppLang.tr('transactions'), '${data.transactions}']);
    writeRow(sheet('Summary'), 7,
        [AppLang.tr('avgSale'), Fmt.money(data.averageSale)]);

    // ── Machines sheet ──
    final mSheet = sheet('Machines');
    writeRow(
        mSheet,
        0,
        [
          AppLang.tr('machine'),
          AppLang.tr('location'),
          AppLang.tr('sales'),
          AppLang.tr('transactions'),
          AppLang.tr('profit'),
          AppLang.tr('commission'),
        ],
        header: true);
    for (var i = 0; i < data.salesByMachine.length; i++) {
      final r = data.salesByMachine[i];
      writeRow(mSheet, i + 1, [
        '${r['machine_name']}',
        '${r['location']}',
        Fmt.money((r['total_sales'] as num?)?.toDouble() ?? 0),
        '${(r['transactions'] as num?)?.toInt() ?? 0}',
        Fmt.money((r['gross_profit'] as num?)?.toDouble() ?? 0),
        Fmt.money((r['commission'] as num?)?.toDouble() ?? 0),
      ]);
    }

    // ── Products sheet ──
    final pSheet = sheet('Products');
    writeRow(
        pSheet,
        0,
        [
          AppLang.tr('product'),
          AppLang.tr('quantitySold'),
          AppLang.tr('revenue'),
          AppLang.tr('costPrice'),
          AppLang.tr('profit'),
        ],
        header: true);
    for (var i = 0; i < data.salesByProduct.length; i++) {
      final r = data.salesByProduct[i];
      writeRow(pSheet, i + 1, [
        '${r['product_name']}',
        Fmt.number((r['total_qty'] as num?)?.toDouble() ?? 0),
        Fmt.money((r['revenue'] as num?)?.toDouble() ?? 0),
        Fmt.money((r['cost'] as num?)?.toDouble() ?? 0),
        Fmt.money((r['profit'] as num?)?.toDouble() ?? 0),
      ]);
    }

    // ── Commission sheet ──
    final cSheet = sheet('Commission');
    writeRow(
        cSheet,
        0,
        [
          AppLang.tr('machine'),
          AppLang.tr('location'),
          AppLang.tr('commissionPercent'),
          AppLang.tr('sales'),
          AppLang.tr('commission'),
        ],
        header: true);
    for (var i = 0; i < data.commissionByMachine.length; i++) {
      final r = data.commissionByMachine[i];
      writeRow(cSheet, i + 1, [
        '${r['machine_name']}',
        '${r['location']}',
        '${(r['commission_percent'] as num?)?.toDouble() ?? 0} %',
        Fmt.money((r['total_sales'] as num?)?.toDouble() ?? 0),
        Fmt.money((r['commission'] as num?)?.toDouble() ?? 0),
      ]);
    }

    // ── Cash sheet ──
    final cashSheet = sheet('Cash');
    writeRow(
        cashSheet,
        0,
        [
          AppLang.tr('machine'),
          AppLang.tr('expected'),
          AppLang.tr('actual'),
          AppLang.tr('difference'),
        ],
        header: true);
    for (var i = 0; i < data.cashSummary.length; i++) {
      final r = data.cashSummary[i];
      writeRow(cashSheet, i + 1, [
        '${r['machine_name']}',
        Fmt.money((r['expected'] as num?)?.toDouble() ?? 0),
        Fmt.money((r['actual'] as num?)?.toDouble() ?? 0),
        Fmt.money((r['difference'] as num?)?.toDouble() ?? 0),
      ]);
    }

    // ── Cash Collection sheet ──
    final collSheet = sheet('Cash Collection');
    writeRow(
        collSheet,
        0,
        [
          AppLang.tr('machine'),
          AppLang.tr('collectionCount'),
          AppLang.tr('totalCollected'),
        ],
        header: true);
    for (var i = 0; i < data.collectionsByMachine.length; i++) {
      final r = data.collectionsByMachine[i];
      writeRow(collSheet, i + 1, [
        '${r['machine_name']}',
        '${(r['collection_count'] as num?)?.toInt() ?? 0}',
        Fmt.money((r['total_collected'] as num?)?.toDouble() ?? 0),
      ]);
    }

    // ── Restocking sheet ──
    final rSheet = sheet('Restocking');
    writeRow(
        rSheet,
        0,
        [
          AppLang.tr('date'),
          AppLang.tr('product'),
          AppLang.tr('quantity'),
          AppLang.tr('unitCost'),
          AppLang.tr('totalCost'),
        ],
        header: true);
    for (var i = 0; i < data.restockingByMachine.length; i++) {
      final r = data.restockingByMachine[i];
      writeRow(rSheet, i + 1, [
        Fmt.date(r['date'] as DateTime?),
        '${r['product_name']}',
        Fmt.number((r['quantity'] as num?)?.toDouble() ?? 0),
        Fmt.money((r['unit_cost'] as num?)?.toDouble() ?? 0),
        Fmt.money((r['total_cost'] as num?)?.toDouble() ?? 0),
      ]);
    }

    // ── Profit sheet ──
    final prSheet = sheet('Profit');
    writeRow(
        prSheet,
        0,
        [
          AppLang.tr('revenue'),
          AppLang.tr('productCost'),
          AppLang.tr('grossProfit'),
          AppLang.tr('commission'),
          AppLang.tr('netProfit'),
        ],
        header: true);
    writeRow(prSheet, 1, [
      Fmt.money(data.totalSales),
      Fmt.money(data.totalCost),
      Fmt.money(data.grossProfit),
      Fmt.money(data.totalCommission),
      Fmt.money(data.netProfit),
    ]);

    // ── Sales sheet (detailed rows) ──
    final sSheet = sheet('Sales');
    writeRow(
        sSheet,
        0,
        [
          AppLang.tr('date'),
          AppLang.tr('machine'),
          AppLang.tr('product'),
          AppLang.tr('quantity'),
          AppLang.tr('total'),
          AppLang.tr('costPrice'),
          AppLang.tr('profit'),
        ],
        header: true);
    // Detailed sales require loading records; the summary list is already in
    // salesByProduct, but for the sheet we include the aggregated rows we have.
    for (var i = 0; i < data.salesByDay.length; i++) {
      final r = data.salesByDay[i];
      writeRow(sSheet, i + 1, [
        '${r['date']}',
        Fmt.number((r['daily_sales'] as num?)?.toDouble() ?? 0),
        Fmt.number((r['daily_sales'] as num?)?.toDouble() ?? 0),
        '—',
        Fmt.number((r['daily_sales'] as num?)?.toDouble() ?? 0),
        '—',
        Fmt.number((r['daily_profit'] as num?)?.toDouble() ?? 0),
      ]);
    }

    // ── Spendings sheet ──
    final spSheet = sheet('Spendings');
    writeRow(
        spSheet,
        0,
        [
          AppLang.tr('date'),
          AppLang.tr('type'),
          AppLang.tr('amount'),
          AppLang.tr('supplier'),
          AppLang.tr('utilityType'),
          AppLang.tr('machine'),
          AppLang.tr('description'),
          AppLang.tr('referenceNumber'),
          AppLang.tr('notes'),
        ],
        header: true);
    for (var i = 0; i < data.spendings.length; i++) {
      final s = data.spendings[i];
      writeRow(spSheet, i + 1, [
        Fmt.date(s.date),
        s.type == SpendingType.inventory
            ? AppLang.tr('inventorySpending')
            : AppLang.tr('utilitiesSpending'),
        Fmt.money(s.amount),
        s.supplier,
        s.utilityType,
        '${s.machineId}',
        s.description,
        s.referenceNumber,
        s.notes,
      ]);
    }

    final saved = excel.save();
    if (saved == null) {
      throw StateError('Excel export failed: save() returned null');
    }
    return Uint8List.fromList(saved);
  }

  /// Saves the workbook to the app documents directory and opens the share
  /// sheet so the user can save it anywhere (e.g. Downloads).
  static Future<void> saveAndOpen(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final file = File(
        '${dir.path}/soultech_report_${now.year}_${now.month.toString().padLeft(2, '0')}.xlsx');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [
        XFile(file.path,
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      ],
    );
  }
}

/// Convenience alias kept for imports written against `ExcelService`.
typedef ExcelService = ExcelReportService;
