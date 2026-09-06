import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/features/qr_creator/qr_creator_controller.dart';
import 'package:soultech_vending/features/qr_creator/qr_data_type.dart';
import 'package:soultech_vending/features/qr_creator/qr_payload_builder.dart';
import 'package:soultech_vending/features/qr_creator/qr_pdf_exporter.dart';
import 'package:soultech_vending/features/qr_creator/qr_png_exporter.dart';

/// QR Creator — the administrator/operator screen to generate machine
/// readable QR codes (URL, phone, text, email, SMS) and export them as
/// PNG or PDF.
///
/// The form and preview stack vertically on phones and sit side-by-side
/// on wide screens (>= 900 px). QR generation is local-only.
class QrCreatorPage extends StatefulWidget {
  const QrCreatorPage({super.key});

  @override
  State<QrCreatorPage> createState() => _QrCreatorPageState();
}

class _QrCreatorPageState extends State<QrCreatorPage> {
  final _controller = QrCreatorController();
  final _formKey = GlobalKey<FormState>();

  // Text controllers (kept alive across type switches to preserve input).
  final _urlCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _textCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  final _pngKey = GlobalKey();
  bool _exporting = false;

  @override
  void dispose() {
    _controller.dispose();
    _urlCtrl.dispose();
    _phoneCtrl.dispose();
    _textCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _onTypeChanged(QrDataType? type) {
    if (type == null || type == _controller.type) return;
    setState(() => _controller.setType(type));
  }

  QrInput get _input => QrInput(
        type: _controller.type,
        url: _urlCtrl.text,
        phone: _phoneCtrl.text,
        text: _textCtrl.text,
        email: _emailCtrl.text,
        subject: _subjectCtrl.text,
        message: _messageCtrl.text,
      );

  void _createQr() {
    // Validate the active fields only.
    if (_formKey.currentState?.validate() != true) return;
    final ok = _controller.generate(_input);
    if (!ok) {
      _snack(AppLang.tr(_controller.errorKey ?? L.qrGenerateFail));
      return;
    }
    _snack(AppLang.tr(L.qrCreated));
  }

  /// Captures the [QrImageView] (white background + margin included by
  /// design) as a high-resolution PNG — not a screen screenshot.
  Future<Uint8List> _captureQrPng() async {
    final boundary =
        _pngKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final size = boundary.size;
    final pixelRatio = size.width > 600 ? 4.0 : 6.0;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final image = await boundary.toImage(pixelRatio: dpr * pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  String get _typeSlug =>
      _controller.type.name; // e.g. webUrl → qr_code_web_url.png

  Future<void> _saveAsPng() async {
    setState(() => _exporting = true);
    try {
      final bytes = await _captureQrPng();
      await QrPngExporter.savePng(bytes, _typeSlug);
      if (mounted) _snack(AppLang.tr(L.savedToDownloads));
    } catch (_) {
      if (mounted) _snack(AppLang.tr(L.exportPngFail));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _saveAsPdf() async {
    setState(() => _exporting = true);
    try {
      final pngBytes = await _captureQrPng();
      final path = await QrPdfExporter.savePdf(
        payload: _controller.payload,
        label: _controller.contentLabel ?? _typeSlug,
        qrPng: pngBytes,
      );
      if (!mounted) return;
      if (path != null) {
        _snack('${AppLang.tr(L.savedToDownloads)}\n$path');
      } else {
        _snack(AppLang.tr(L.savedFileName));
      }
    } catch (_) {
      if (mounted) _snack(AppLang.tr(L.exportPdfFail));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _shareAsPng() async {
    setState(() => _exporting = true);
    try {
      final bytes = await _captureQrPng();
      await QrPngExporter.sharePng(bytes, _typeSlug);
    } catch (_) {
      if (mounted) _snack(AppLang.tr(L.shareFail));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _shareAsPdf() async {
    setState(() => _exporting = true);
    try {
      final pngBytes = await _captureQrPng();
      await QrPdfExporter.sharePdf(
        payload: _controller.payload,
        label: _controller.contentLabel ?? _typeSlug,
        qrPng: pngBytes,
      );
    } catch (_) {
      if (mounted) _snack(AppLang.tr(L.shareFail));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLang.tr(L.qrCreator)),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => IconButton(
              onPressed: _controller.status == QrCreatorStatus.generated
                  ? () => setState(_controller.reset)
                  : null,
              icon: const Icon(Icons.refresh),
              tooltip: AppLang.tr('refresh'),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildForm(context)),
                      const SizedBox(width: 20),
                      Expanded(child: _buildPreview(context)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildForm(context),
                      const SizedBox(height: 20),
                      _buildPreview(context),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLang.tr(L.qrCreator),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          AppLang.tr(L.qrCreatorSubtitle),
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  final type = _controller.type;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Data type selector
                      DropdownButtonFormField<QrDataType>(
                        initialValue: type,
                        decoration:
                            InputDecoration(labelText: AppLang.tr(L.dataType)),
                        items: [
                          for (final t in QrTypes.all)
                            DropdownMenuItem(
                              value: t.type,
                              child: Text(t.label),
                            ),
                        ],
                        onChanged: _onTypeChanged,
                      ),
                      const SizedBox(height: 16),
                      ..._fieldsFor(type),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _createQr,
                        icon: const Icon(Icons.qr_code_2),
                        label: Text(AppLang.tr(L.createQr)),
                        style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _fieldsFor(QrDataType type) {
    switch (type) {
      case QrDataType.webUrl:
        return [
          TextFormField(
            controller: _urlCtrl,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: AppLang.tr(L.websiteUrl),
              hintText: 'https://example.com',
              prefixIcon: const Icon(Icons.link),
              helperText: '${AppLang.tr(L.invalidUrl)}: missing https://',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return AppLang.tr(L.requiredField);
              }
              if (!QrPayloadBuilder.isUrl(v)) return AppLang.tr(L.invalidUrl);
              return null;
            },
          ),
        ];
      case QrDataType.phone:
        return [
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: AppLang.tr(L.phoneNumber),
              hintText: '+218910461043',
              prefixIcon: const Icon(Icons.phone),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return AppLang.tr(L.requiredField);
              }
              final digits = v.replaceAll(RegExp(r'[^0-9+]'), '');
              if (digits.isEmpty || digits.length < 7) {
                return AppLang.tr(L.invalidPhone);
              }
              return null;
            },
          ),
        ];
      case QrDataType.text:
        return [
          TextFormField(
            controller: _textCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: AppLang.tr(L.text),
              hintText: 'Hello from Soultech Vending',
              alignLabelWithHint: true,
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? AppLang.tr(L.requiredField)
                : null,
          ),
        ];
      case QrDataType.email:
        return [
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: AppLang.tr(L.emailAddress),
              hintText: 'name@example.com',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return AppLang.tr(L.requiredField);
              }
              final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!re.hasMatch(v.trim())) return AppLang.tr(L.invalidUrl);
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _subjectCtrl,
            decoration: InputDecoration(
              labelText: AppLang.tr(L.subject),
              prefixIcon: const Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _messageCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: AppLang.tr(L.message),
              alignLabelWithHint: true,
            ),
          ),
        ];
      case QrDataType.sms:
        return [
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: AppLang.tr(L.phoneNumber),
              hintText: '+218910461043',
              prefixIcon: const Icon(Icons.phone),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return AppLang.tr(L.requiredField);
              }
              final digits = v.replaceAll(RegExp(r'[^0-9+]'), '');
              if (digits.isEmpty || digits.length < 7) {
                return AppLang.tr(L.invalidPhone);
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _messageCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: AppLang.tr(L.message),
              alignLabelWithHint: true,
            ),
          ),
        ];
    }
  }

  Widget _buildPreview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final status = _controller.status;
            final generated = status == QrCreatorStatus.generated;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLang.tr(L.qrPreview),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                // QR display area
                Container(
                  height: 260,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: generated
                      ? Center(
                          child: RepaintBoundary(
                            key: _pngKey,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: QrImageView(
                                data: _controller.payload,
                                version: QrVersions.auto,
                                size: 220,
                                padding: const EdgeInsets.all(20),
                                backgroundColor: Colors.white,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Colors.black,
                                ),
                                errorCorrectionLevel: QrErrorCorrectLevel.H,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                size: 72,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                AppLang.tr(L.qrPlaceholder),
                                style: TextStyle(color: Colors.grey.shade500),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                ),
                if (generated) ...[
                  const SizedBox(height: 16),
                  _infoRow(
                    AppLang.tr(L.dataType),
                    _controller.contentLabel ?? '',
                  ),
                  const SizedBox(height: 8),
                  _infoRow(AppLang.tr(L.content), _controller.payload),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _exporting ? null : _saveAsPng,
                          icon: const Icon(Icons.image_outlined),
                          label: Text(AppLang.tr(L.saveAsPng)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _exporting ? null : _saveAsPdf,
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: Text(AppLang.tr(L.saveAsPdf)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _exporting ? null : _shareAsPng,
                          icon: const Icon(Icons.ios_share),
                          label: Text(AppLang.tr(L.sharePng)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _exporting ? null : _shareAsPdf,
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: Text(AppLang.tr(L.sharePdf)),
                        ),
                      ),
                    ],
                  ),
                  if (_exporting) ...[
                    const SizedBox(height: 12),
                    const Center(
                        child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
                color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
