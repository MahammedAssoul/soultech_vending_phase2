import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/services/backup_service.dart';
import 'package:soultech_vending/core/services/csv_import_service.dart';
import 'package:soultech_vending/core/theme/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _busy = false;

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _toggleLanguage() async {
    setState(() {
      AppLang.current = AppLang.isAr ? 'en' : 'ar';
    });
    _snack(AppLang.isAr
        ? AppLang.tr('switchToArabic')
        : AppLang.tr('switchToEnglish'));
  }

  Future<void> _exportBackup() async {
    setState(() => _busy = true);
    try {
      await BackupService.exportBackup();
      _snack(AppLang.tr('backupCreated'));
    } catch (e) {
      _snack('${AppLang.tr('exportFail')}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreBackup() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (file == null) return;
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLang.tr('confirmRestoreTitle')),
        content: Text(AppLang.tr('confirmRestore')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLang.tr('cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLang.tr('restoreBackup'))),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      await BackupService.restoreBackup(file.path);
      _snack(AppLang.tr('restoreComplete'));
    } catch (e) {
      _snack('${AppLang.tr('exportFail')}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importCsv() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CSV', extensions: ['csv']),
      ],
    );
    if (file == null) return;
    setState(() => _busy = true);
    try {
      final result = await CsvImportService.importSales(file.path);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLang.tr('importSummary')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow(AppLang.tr('imported'), '${result.imported}'),
              _summaryRow(AppLang.tr('skipped'), '${result.skipped}'),
              _summaryRow(AppLang.tr('errors'), '${result.errors}'),
              if (result.errorMessages.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(AppLang.tr('errors'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final e in result.errorMessages.take(20))
                          Text('• $e', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLang.tr('close'))),
          ],
        ),
      );
    } catch (e) {
      _snack('${AppLang.tr('exportFail')}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _summaryRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(AppLang.tr('settings'))),
        body: _busy
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Language
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(AppLang.tr('language')),
                      subtitle: Text(AppLang.isAr
                          ? AppLang.tr('arabic')
                          : AppLang.tr('english')),
                      trailing: Switch(
                        value: AppLang.isAr,
                        onChanged: (_) => _toggleLanguage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Theme
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.brightness_6),
                      title: Text(AppLang.tr('theme')),
                      subtitle: Text(ThemeController.instance.isDark
                          ? AppLang.tr('darkMode')
                          : AppLang.tr('lightMode')),
                      trailing: Switch(
                        value: ThemeController.instance.isDark,
                        onChanged: (_) => ThemeController.instance.toggle(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Import CSV
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.upload_file_outlined),
                      title: Text(AppLang.tr('importCsv')),
                      subtitle: Text(
                          'date, machine, product, quantity, unitPrice, costPrice, notes'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _importCsv,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Export backup
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.backup_outlined),
                      title: Text(AppLang.tr('exportBackup')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _exportBackup,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Restore backup
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.restore_outlined),
                      title: Text(AppLang.tr('restoreBackup')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _restoreBackup,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Soultech Vending • ${AppLang.tr('tagline')}',
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ),
                ],
              ),
      );
}
