import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/theme/app_theme.dart';
import 'package:soultech_vending/core/utils/format.dart';
import 'package:soultech_vending/core/widgets/empty_state.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/features/receipts/pdf_receipt_service.dart';
import 'package:soultech_vending/features/receipts/sales_receipt_service.dart';

/// Step 2: the detailed monthly cash settlement receipt for one machine.
class ReceiptDetailsPage extends StatefulWidget {
  const ReceiptDetailsPage({
    super.key,
    required this.machine,
    required this.month,
  });

  final Machine machine;
  final DateTime month;

  @override
  State<ReceiptDetailsPage> createState() => _ReceiptDetailsPageState();
}

class _ReceiptDetailsPageState extends State<ReceiptDetailsPage> {
  bool _loading = true;
  String? _error;
  SalesReceipt? _receipt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final receipt = await SalesReceiptService().build(
        machineId: widget.machine.id!,
        month: widget.month,
      );
      if (!mounted) return;
      setState(() {
        _receipt = receipt;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _sharePdf() async {
    if (_receipt == null) return;
    try {
      await PdfReceiptService.sharePdf(_receipt!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLang.tr('exportFail')}: $e')));
    }
  }

  Future<void> _savePdf() async {
    if (_receipt == null) return;
    try {
      final savedToDownloads = await PdfReceiptService.savePdf(_receipt!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(savedToDownloads
              ? AppLang.tr('savedToDownloads')
              : AppLang.tr('exportSuccess'))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLang.tr('exportFail')}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLang.tr('receiptDetails')),
        actions: [
          PopupMenuButton<String>(
            enabled: _receipt != null,
            tooltip: AppLang.tr('exportPdf'),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onSelected: (value) {
              switch (value) {
                case 'save':
                  _savePdf();
                case 'share':
                  _sharePdf();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'save',
                child: ListTile(
                  leading: const Icon(Icons.save_alt_outlined),
                  title: Text(AppLang.tr('saveReceipt')),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: Text(AppLang.tr('shareReceipt')),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? EmptyState(
                  icon: Icons.error_outline,
                  title: AppLang.tr('error'),
                  message: _error!,
                )
              : _buildBody(_receipt!),
    );
  }

  Widget _buildBody(SalesReceipt r) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _headerCard(r),
        const SizedBox(height: 16),
        _summaryCard(r),
        const SizedBox(height: 16),
        _transactionsCard(r),
      ],
    );
  }

  Widget _headerCard(SalesReceipt r) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_shipping,
                color: AppColors.blue, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.machine.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                Text('${r.machine.code} • ${r.machine.location}',
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(DateFormat('MMMM yyyy').format(r.month),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
                '${AppLang.tr('commissionPercent')} '
                '${r.commissionPercent.toStringAsFixed(1)}%',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ]),
        ]),
      ),
    );
  }

  Widget _summaryCard(SalesReceipt r) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLang.tr('monthlyTotals'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _row(AppLang.tr('totalCollectedCash'), Fmt.money(r.totalCollected),
                color: Colors.green),
            _row(AppLang.tr('totalAddedChange'), Fmt.money(r.totalAddedChange),
                color: Colors.blue),
            const Divider(height: 20),
            _row(AppLang.tr('netAmount'), Fmt.money(r.netAmount),
                highlight: true),
            const Divider(height: 20),
            _row(
              AppLang.tr('commission'),
              '${r.commissionPercent.toStringAsFixed(1)}%',
            ),
            _row(AppLang.tr('commissionAmount'), Fmt.money(r.commissionAmount),
                highlight: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value,
      {bool highlight = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
            fontSize: highlight ? 18 : 15,
            color: color ?? (highlight ? AppColors.navy : Colors.black87),
          ),
        ),
      ]),
    );
  }

  Widget _transactionsCard(SalesReceipt r) {
    if (r.transactions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: AppLang.tr('noRecordsYet'),
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLang.tr('transactions'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final t in r.transactions)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  t.isCollection
                      ? Icons.payments_outlined
                      : Icons.savings_outlined,
                  color: t.isCollection ? Colors.green : Colors.blue,
                  size: 20,
                ),
                title: Text(DateFormat('dd/MM/yyyy').format(t.date)),
                subtitle: Text(
                  t.notes.isEmpty ? '' : t.notes,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  t.isCollection
                      ? '+ ${Fmt.money(t.amount)}'
                      : '- ${Fmt.money(t.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: t.isCollection ? Colors.green : Colors.blue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
