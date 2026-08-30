import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/theme/app_theme.dart';
import 'package:soultech_vending/core/utils/format.dart';
import 'package:soultech_vending/core/widgets/empty_state.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/features/receipts/receipt_details_page.dart';
import 'package:soultech_vending/features/receipts/sales_receipt_service.dart';

/// Step 1: pick a month + machine, then open the receipt details.
class SalesReceiptPage extends StatefulWidget {
  const SalesReceiptPage({super.key});
  @override
  State<SalesReceiptPage> createState() => _SalesReceiptPageState();
}

class _SalesReceiptPageState extends State<SalesReceiptPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _loading = true;
  String? _error;
  List<Map<String, Object?>> _summaries = [];

  final _service = SalesReceiptService();

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
      final summaries = await _service.machineSummaries(_month);
      if (!mounted) return;
      setState(() {
        _summaries = summaries;
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

  Future<void> _pickMonth() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: AppLang.tr('selectMonth'),
    );
    if (d != null) {
      setState(() => _month = DateTime(d.year, d.month, 1));
      _load();
    }
  }

  void _openMachine(Machine m) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptDetailsPage(machine: m, month: _month),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLang.tr('salesReceipt'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? EmptyState(
                  icon: Icons.error_outline,
                  title: AppLang.tr('error'),
                  message: _error!,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Month picker card
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_month,
                              color: AppColors.navy),
                          title: Text(AppLang.tr('month')),
                          subtitle:
                              Text(DateFormat('MMMM yyyy').format(_month)),
                          trailing: const Icon(Icons.edit_calendar_outlined),
                          onTap: _pickMonth,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(AppLang.tr('machines'),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      if (_summaries.isEmpty)
                        const EmptyState(
                          icon: Icons.local_shipping_outlined,
                          title: '',
                          message: '',
                        )
                      else
                        ..._summaries.map((row) {
                          final m = row['machine'] as Machine;
                          final collected =
                              (row['totalCollected'] as num?)?.toDouble() ?? 0;
                          final net =
                              (row['netAmount'] as num?)?.toDouble() ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.blue.withValues(alpha: .1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.local_shipping,
                                      color: AppColors.blue),
                                ),
                                title: Text(m.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                subtitle: Text(
                                  '${m.code} • ${m.location}',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(Fmt.money(collected),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800)),
                                    Text(
                                      '${AppLang.tr('netAmount')}: ${Fmt.money(net)}',
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                                onTap: () => _openMachine(m),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}
