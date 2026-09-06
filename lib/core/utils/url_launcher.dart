import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the system's default external browser.
///
/// Returns `true` when the browser could be opened, `false` otherwise
/// (for example when no browser is installed or the URL is invalid).
Future<bool> launchExternalUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
