import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Exports a QR code as a high-resolution PNG.
///
/// Works on Android / iOS / desktop without requesting storage
/// permissions: the file is written to the app documents directory and
/// handed to the system share sheet, or saved to Downloads when the
/// platform exposes a downloads directory (`getDownloadsDirectory`).
class QrPngExporter {
  const QrPngExporter._();

  /// Builds a safe lowercase filename for [type]:
  /// e.g. `qr_code_web_url.png` or `qr_code_<timestamp>.png`.
  static String fileName(String type,
      {DateTime? now, bool withTimestamp = false}) {
    final ts = now ?? DateTime.now();
    final base =
        type.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final name = base.isEmpty ? 'qr_code' : 'qr_code_$base';
    return withTimestamp
        ? '$name${ts.millisecondsSinceEpoch}.png'
        : '$name.png';
  }

  /// Writes [pngBytes] to Downloads when available, otherwise to the app
  /// documents directory. Returns the path of the written file.
  static Future<String> savePng(Uint8List pngBytes, String type) async {
    final downloads = await getDownloadsDirectory();
    final dir = downloads ?? await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${fileName(type)}');
    await file.writeAsBytes(pngBytes, flush: true);
    return file.path;
  }

  /// Writes [pngBytes] to the app documents directory and opens the
  /// system share sheet.
  static Future<void> sharePng(Uint8List pngBytes, String type) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${fileName(type)}');
    await file.writeAsBytes(pngBytes, flush: true);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
    );
  }
}
