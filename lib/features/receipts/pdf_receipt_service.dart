import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/utils/format.dart';
import 'package:soultech_vending/features/receipts/sales_receipt_service.dart';

/// Generates the A4 branded PDF cash-settlement receipt for a machine.
///
/// Mirrors the receipt details screen exactly (same model).
class PdfReceiptService {
  const PdfReceiptService._();

  static Future<Uint8List> build(SalesReceipt receipt) async {
    final doc = pw.Document();
    final navy = PdfColor.fromInt(0xFF123C73);
    final blue = PdfColor.fromInt(0xFF1689E8);
    final grey = PdfColor.fromInt(0xFF6B7280);

    pw.Widget header(String text) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Text(text,
              style: pw.TextStyle(
                  fontSize: 15, fontWeight: pw.FontWeight.bold, color: navy)),
        );

    pw.Widget row(String label, String value, {bool bold = false}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
                pw.Text(value,
                    style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: bold ? pw.FontWeight.bold : null)),
              ]),
        );

    pw.Table tableFrom(List<List<String>> rows, {List<double>? widths}) {
      final cols = rows.first.length;
      final effWidths = widths ?? List<double>.filled(cols, 1, growable: false);
      return pw.Table(
        columnWidths: {
          for (var i = 0; i < cols; i++) i: pw.FlexColumnWidth(effWidths[i]),
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

    final monthLabel = DateFormat('MMMM yyyy').format(receipt.month);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          // Branded header
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
                pw.Text(AppLang.tr('salesReceipt'),
                    style: pw.TextStyle(
                        fontSize: 15, fontWeight: pw.FontWeight.bold)),
              ]),
          pw.SizedBox(height: 4),
          pw.Divider(color: blue, thickness: 1.5),
          pw.SizedBox(height: 12),

          // Machine info
          row(receipt.machine.name,
              '${receipt.machine.code} • ${receipt.machine.location}'),
          row(AppLang.tr('month'), monthLabel),
          row('${AppLang.tr('commissionPercent')}',
              '${receipt.commissionPercent.toStringAsFixed(1)}%'),
          pw.SizedBox(height: 16),

          // Monthly settlement totals
          header(AppLang.tr('monthlyTotals')),
          row(AppLang.tr('totalCollectedCash'),
              Fmt.money(receipt.totalCollected)),
          row(AppLang.tr('totalAddedChange'),
              Fmt.money(receipt.totalAddedChange)),
          pw.Divider(color: grey.withValues(0.3, null, null, null)),
          row(AppLang.tr('netAmount'), Fmt.money(receipt.netAmount),
              bold: true),
          pw.Divider(color: grey.withValues(0.3, null, null, null)),
          row(AppLang.tr('commission'),
              '${receipt.commissionPercent.toStringAsFixed(1)}%'),
          row(AppLang.tr('commissionAmount'),
              Fmt.money(receipt.commissionAmount),
              bold: true),
          pw.SizedBox(height: 16),

          // Transactions (collections + change)
          header(AppLang.tr('transactions')),
          tableFrom([
            [AppLang.tr('date'), AppLang.tr('type'), AppLang.tr('amount')],
            ...receipt.transactions.map((t) => [
                  DateFormat('dd/MM/yyyy').format(t.date),
                  t.isCollection
                      ? AppLang.tr('cashCollectionsShort')
                      : AppLang.tr('changeAdded'),
                  t.isCollection
                      ? '+ ${Fmt.money(t.amount)}'
                      : '- ${Fmt.money(t.amount)}',
                ]),
          ]),
          pw.SizedBox(height: 16),

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

  static Future<void> export(SalesReceipt receipt) async {
    final bytes = await build(receipt);
    final year = receipt.month.year;
    final mm = receipt.month.month.toString().padLeft(2, '0');
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'soultech_receipt_${receipt.machine.code}_${year}_$mm.pdf',
    );
  }
}
