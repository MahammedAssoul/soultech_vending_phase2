import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/theme/app_theme.dart';
import 'package:soultech_vending/core/utils/format.dart';
import 'package:soultech_vending/core/widgets/empty_state.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/repositories/cash_collection_repository.dart';
import 'package:soultech_vending/data/repositories/change_added_repository.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';

/// Commission details for a selected month.
///
/// Shows the total commission amount for the month, a month switcher, and a
/// list of all machines with their commission percentage and the commission
/// amount for the selected month (net collected × commission %).
class CommissionDetailsPage extends StatefulWidget {
  const CommissionDetailsPage({super.key});
  @override
  State<CommissionDetailsPage> createState() => _CommissionDetailsPageState();
}

class _CommissionDetailsPageState extends State<CommissionDetailsPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _loading = true;
  String? _error;
  List<Map<String, Object?>> _rows = [];

  final _machineRepo = MachineRepository();
  final _collectionRepo = CashCollectionRepository();
  final _changeRepo = ChangeAddedRepository();

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
      final from = DateTime(_month.year, _month.month, 1);
      final to = DateTime(_month.year, _month.month + 1, 0);

      final machines = await _machineRepo.getAll();
      final rows = <Map<String, Object?>>[];
      for (final m in machines) {
        final id = m.id;
        if (id == null) continue;
        final collected =
            await _collectionRepo.getTotal(machineId: id, from: from, to: to);
        final change =
            await _changeRepo.getTotalByMachine(id, from: from, to: to);
        final net = collected - change;
        rows.add({
          'machine': m,
          'netAmount': net,
          'commissionAmount': net * (m.commissionPercent / 100),
        });
      }
      rows.sort((a, b) => ((b['commissionAmount'] as num?)?.toDouble() ?? 0)
          .compareTo((a['commissionAmount'] as num?)?.toDouble() ?? 0));

      if (!mounted) return;
      setState(() {
        _rows = rows;
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

  double get _totalCommission => _rows.fold<double>(
      0, (sum, r) => sum + ((r['commissionAmount'] as num?)?.toDouble() ?? 0));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLang.tr('commissionReport'))),
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
                      // Total commission for the selected month
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.lightBlue.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.percent,
                                    color: AppColors.lightBlue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppLang.tr('thisMonthCommission'),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                Fmt.money(_totalCommission),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLang.tr('machines'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      if (_rows.isEmpty)
                        const EmptyState(
                          icon: Icons.local_shipping_outlined,
                          title: '',
                          message: '',
                        )
                      else
                        ..._rows.map((row) {
                          final m = row['machine'] as Machine;
                          final commission =
                              (row['commissionAmount'] as num?)?.toDouble() ??
                                  0;
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
                                    Text(
                                      Fmt.money(commission),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      '${AppLang.tr('commissionPercent')} '
                                      '${m.commissionPercent.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
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
