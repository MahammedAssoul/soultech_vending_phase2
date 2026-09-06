import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';

/// Exports a QR code as a print-ready A4 PDF.
///
/// The PDF embeds a high-resolution PNG of the QR on a white card with a
/// generous quiet zone, centered on the page; the payload is also included
/// as text below the QR so it stays usable even if the image is damaged.
///
/// Reuses the project's `pdf` + `printing` + `share_plus` architecture
/// (same as the receipt PDFs).
class QrPdfExporter {
  const QrPdfExporter._();

  /// Safe A4-flavored filename: `qr_code_web_url.pdf`.
  static String fileName(String type) {
    final base =
        type.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return '${base.isEmpty ? 'qr_code' : 'qr_code_$base'}.pdf';
  }

  /// Builds the A4 PDF bytes for [payload] (with [label] and [qrPng]).
  static Future<Uint8List> buildPdf({
    required String payload,
    required String label,
    required Uint8List qrPng,
  }) async {
    final doc = pw.Document();
    final navy = PdfColor.fromInt(0xFF123C73);
    final grey = PdfColor.fromInt(0xFF6B7280);

    final image = pw.MemoryImage(qrPng);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(height: 6),
            pw.Text('QR CODE',
                style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 3,
                    color: navy)),
            pw.SizedBox(height: 24),
            // Centered large QR with surrounding white quiet zone.
            pw.Container(
              padding: const pw.EdgeInsets.all(28),
              color: PdfColors.white,
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Image(image,
                      width: PdfPageFormat.a4.availableWidth - 56 * 2,
                      height: PdfPageFormat.a4.availableWidth - 56 * 2,
                      fit: pw.BoxFit.contain),
                ],
              ),
            ),
            pw.SizedBox(height: 28),
            pw.Text('QR Creator',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold, color: navy)),
            pw.SizedBox(height: 4),
            pw.Text(label, style: pw.TextStyle(fontSize: 13, color: grey)),
            pw.SizedBox(height: 12),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 24),
              child: pw.Text(payload,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.black)),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Soultech Vending • ${AppLang.tr('tagline')}',
                style: pw.TextStyle(fontSize: 8, color: grey)),
          ],
        ),
      ),
    );

    return doc.save();
  }

  /// Saves the PDF to Downloads (or documents dir) and returns the path.
  static Future<String?> savePdf({
    required String payload,
    required String label,
    required Uint8List qrPng,
  }) async {
    final bytes = await buildPdf(payload: payload, label: label, qrPng: qrPng);
    final downloads = await getDownloadsDirectory();
    final dir = downloads ?? await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${fileName(label)}');
    await file.writeAsBytes(bytes, flush: true);
    if (downloads != null) {
      return file.path;
    }
    return null;
  }

  /// Opens the system share sheet with the generated PDF.
  static Future<void> sharePdf({
    required String payload,
    required String label,
    required Uint8List qrPng,
  }) async {
    final bytes = await buildPdf(payload: payload, label: label, qrPng: qrPng);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${fileName(label)}');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
    );
  }

  /// Prints the PDF via the system print dialog.
  static Future<void> printPdf({
    required String payload,
    required String label,
    required Uint8List qrPng,
  }) async {
    final bytes = await buildPdf(payload: payload, label: label, qrPng: qrPng);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: fileName(label),
    );
  }
}
