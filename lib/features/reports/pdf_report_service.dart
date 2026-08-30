import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/utils/format.dart';
import 'package:soultech_vending/features/reports/report_service.dart';

/// Generates a branded PDF report for the currently selected report period.
class PdfReportService {
  const PdfReportService._();

  /// Builds the PDF document bytes for [data].
  static Future<Uint8List> build(ReportData data,
      {required String title}) async {
    final doc = pw.Document();
    final navy = PdfColor.fromInt(0xFF123C73);
    final blue = PdfColor.fromInt(0xFF1689E8);
    final grey = PdfColor.fromInt(0xFF6B7280);

    pw.Widget header(String text) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Text(text,
              style: pw.TextStyle(
                  fontSize: 16, fontWeight: pw.FontWeight.bold, color: navy)),
        );

    pw.Widget summaryRow(String label, String value) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
                pw.Text(value,
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ]),
        );

    pw.Table tableFrom(List<List<String>> rows, {List<double>? widths}) {
      final cols = rows.first.length;
      final effectiveWidths =
          widths ?? List<double>.filled(cols, 1, growable: false);
      return pw.Table(
        columnWidths: {
          for (var i = 0; i < cols; i++)
            i: pw.FlexColumnWidth(effectiveWidths[i]),
        },
        border: pw.TableBorder.all(
            color: grey.withValues(0.3, null, null, null), width: 0.5),
        children: [
          for (var r = 0; r < rows.length; r++)
            pw.TableRow(
              decoration: r == 0
                  ? pw.BoxDecoration(
                      color: navy.withValues(0.08, null, null, null))
                  : null,
              children: [
                for (var c = 0; c < cols; c++)
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(rows[r][c],
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: r == 0 ? pw.FontWeight.bold : null)),
                  ),
              ],
            ),
        ],
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          // Header
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Soultech Vending',
                          style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: navy)),
                      pw.Text(AppLang.tr('tagline'),
                          style: pw.TextStyle(fontSize: 9, color: grey)),
                    ]),
                pw.Text(title,
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ]),
          pw.SizedBox(height: 4),
          pw.Divider(color: blue, thickness: 1.5),
          pw.SizedBox(height: 12),

          // Summary
          header(AppLang.tr('summary')),
          summaryRow(AppLang.tr('totalSales'), Fmt.money(data.totalSales)),
          summaryRow(AppLang.tr('totalCost'), Fmt.money(data.totalCost)),
          summaryRow(AppLang.tr('grossProfit'), Fmt.money(data.grossProfit)),
          summaryRow(
              AppLang.tr('totalCommission'), Fmt.money(data.totalCommission)),
          summaryRow(AppLang.tr('netProfit'), Fmt.money(data.netProfit)),
          summaryRow(AppLang.tr('transactions'), '${data.transactions}'),
          summaryRow(AppLang.tr('avgSale'), Fmt.money(data.averageSale)),
          pw.SizedBox(height: 16),

          // Spending
          if (data.totalSpending != 0) ...[
            header(AppLang.tr('spending')),
            summaryRow(AppLang.tr('inventorySpending'),
                Fmt.money(data.inventorySpending)),
            summaryRow(AppLang.tr('utilitiesSpending'),
                Fmt.money(data.utilitiesSpending)),
            pw.Divider(color: grey.withValues(0.3, null, null, null)),
            summaryRow(
                AppLang.tr('totalSpending'), Fmt.money(data.totalSpending)),
            pw.SizedBox(height: 16),
          ],

          // Machine performance
          if (data.salesByMachine.isNotEmpty) ...[
            header(AppLang.tr('machinePerformance')),
            tableFrom([
              [
                AppLang.tr('machine'),
                AppLang.tr('location'),
                AppLang.tr('sales'),
                AppLang.tr('transactions'),
                AppLang.tr('profit'),
                AppLang.tr('commission')
              ],
              ...data.salesByMachine.map((r) => [
                    '${r['machine_name']}',
                    '${r['location']}',
                    Fmt.money((r['total_sales'] as num?)?.toDouble() ?? 0),
                    '${(r['transactions'] as num?)?.toInt() ?? 0}',
                    Fmt.money((r['gross_profit'] as num?)?.toDouble() ?? 0),
                    Fmt.money((r['commission'] as num?)?.toDouble() ?? 0),
                  ]),
            ]),
            pw.SizedBox(height: 16),
          ],

          // Product performance
          if (data.salesByProduct.isNotEmpty) ...[
            header(AppLang.tr('productPerformance')),
            tableFrom([
              [
                AppLang.tr('product'),
                AppLang.tr('quantitySold'),
                AppLang.tr('revenue'),
                AppLang.tr('costPrice'),
                AppLang.tr('profit')
              ],
              ...data.salesByProduct.map((r) => [
                    '${r['product_name']}',
                    Fmt.number((r['total_qty'] as num?)?.toDouble() ?? 0),
                    Fmt.money((r['revenue'] as num?)?.toDouble() ?? 0),
                    Fmt.money((r['cost'] as num?)?.toDouble() ?? 0),
                    Fmt.money((r['profit'] as num?)?.toDouble() ?? 0),
                  ]),
            ]),
            pw.SizedBox(height: 16),
          ],

          // Restocking
          if (data.restockingByMachine.isNotEmpty) ...[
            header(AppLang.tr('restockingReport')),
            tableFrom([
              [
                AppLang.tr('date'),
                AppLang.tr('product'),
                AppLang.tr('quantity'),
                AppLang.tr('unitCost'),
                AppLang.tr('totalCost')
              ],
              ...data.restockingByMachine.map((r) => [
                    Fmt.date((r['date'] as DateTime?)),
                    '${r['product_name']}',
                    Fmt.number((r['quantity'] as num?)?.toDouble() ?? 0),
                    Fmt.money((r['unit_cost'] as num?)?.toDouble() ?? 0),
                    Fmt.money((r['total_cost'] as num?)?.toDouble() ?? 0),
                  ]),
            ]),
            pw.SizedBox(height: 16),
          ],

          // Cash
          if (data.cashSummary.isNotEmpty) ...[
            header(AppLang.tr('cashReport')),
            tableFrom([
              [
                AppLang.tr('machine'),
                AppLang.tr('expected'),
                AppLang.tr('actual'),
                AppLang.tr('difference')
              ],
              ...data.cashSummary.map((r) => [
                    '${r['machine_name']}',
                    Fmt.money((r['expected'] as num?)?.toDouble() ?? 0),
                    Fmt.money((r['actual'] as num?)?.toDouble() ?? 0),
                    Fmt.money((r['difference'] as num?)?.toDouble() ?? 0),
                  ]),
            ]),
            pw.SizedBox(height: 16),
          ],

          // Cash Collection
          if (data.collectionsByMachine.isNotEmpty) ...[
            header(AppLang.tr('collectionReport')),
            tableFrom([
              [
                AppLang.tr('machine'),
                AppLang.tr('collectionCount'),
                AppLang.tr('totalCollected')
              ],
              ...data.collectionsByMachine.map((r) => [
                    '${r['machine_name']}',
                    '${(r['collection_count'] as num?)?.toInt() ?? 0}',
                    Fmt.money((r['total_collected'] as num?)?.toDouble() ?? 0),
                  ]),
            ]),
            pw.SizedBox(height: 16),
          ],

          pw.SizedBox(height: 8),
          pw.Divider(color: grey.withValues(0.3, null, null, null)),
          pw.SizedBox(height: 4),
          pw.Text(
            'Soultech Vending • ${AppLang.tr('tagline')}',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 8, color: grey),
          ),
        ],
      ),
    );

    return doc.save();
  }

  /// Builds and shares/saves the PDF via the printing package.
  static Future<void> export(ReportData data, {required String title}) async {
    final bytes = await build(data, title: title);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: _filename(title),
    );
  }

  static String _filename(String title) {
    final now = DateTime.now();
    final safe = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return 'soultech_${safe}_${now.year}_${now.month.toString().padLeft(2, '0')}.pdf';
  }
}

/// Convenience alias kept for imports written against `PdfService`.
typedef PdfService = PdfReportService;
