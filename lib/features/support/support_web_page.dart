import 'package:flutter/material.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/utils/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Default customer support URL opened from the Settings page.
const String kSupportSiteUrl = 'https://soultech-support.web.app/admin';

/// In-app web page that renders the customer support site.
///
/// Shows a loader while the page loads, a reload button when offline or on
/// error, and lets the user jump to the external browser from the app bar.
class SupportWebPage extends StatefulWidget {
  const SupportWebPage({super.key, this.url = kSupportSiteUrl});

  /// The URL to display. Defaults to [kSupportSiteUrl].
  final String url;

  @override
  State<SupportWebPage> createState() => _SupportWebPageState();
}

class _SupportWebPageState extends State<SupportWebPage> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _loading = progress < 100);
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                _loading = false;
                _failed = false;
              });
            }
          },
          onWebResourceError: (error) {
            if (mounted) setState(() => _failed = true);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _openExternal() async {
    final url = widget.url;
    final launched = await launchExternalUrl(url);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLang.tr('error')}: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLang.tr('supportSiteTitle')),
        actions: [
          IconButton(
            onPressed: _openExternal,
            icon: const Icon(Icons.open_in_new),
            tooltip: AppLang.tr('openExternal'),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_failed)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    AppLang.tr('error'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() => _failed = false);
                      _controller.reload();
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(AppLang.tr('retry')),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
