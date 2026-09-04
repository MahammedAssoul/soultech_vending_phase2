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
import 'package:soultech_vending/data/repositories/spending_repository.dart';

/// Profit details for a selected month.
///
/// Shows the total profit (collected − spending − commission), a month
/// switcher, a breakdown of the profit components, and a per-machine profit
/// list for the selected month.
class ProfitDetailsPage extends StatefulWidget {
  const ProfitDetailsPage({super.key});
  @override
  State<ProfitDetailsPage> createState() => _ProfitDetailsPageState();
}

class _ProfitDetailsPageState extends State<ProfitDetailsPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _loading = true;
  String? _error;

  double _collected = 0;
  double _spending = 0;
  double _inventorySpending = 0;
  double _utilitiesSpending = 0;
  double _commission = 0;
  List<Map<String, Object?>> _rows = [];

  final _machineRepo = MachineRepository();
  final _collectionRepo = CashCollectionRepository();
  final _changeRepo = ChangeAddedRepository();
  final _spendingRepo = SpendingRepository();

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

      final collected = await _collectionRepo.getTotal(from: from, to: to);
      final spending = await _spendingRepo.getTotals(from: from, to: to);
      final machines = await _machineRepo.getAll();

      final rows = <Map<String, Object?>>[];
      var commission = 0.0;
      for (final m in machines) {
        final id = m.id;
        if (id == null) continue;
        final mCollected =
            await _collectionRepo.getTotal(machineId: id, from: from, to: to);
        final mChange =
            await _changeRepo.getTotalByMachine(id, from: from, to: to);
        final net = mCollected - mChange;
        final mCommission = net * (m.commissionPercent / 100);
        commission += mCommission;
        rows.add({
          'machine': m,
          'netAmount': net,
          'commissionAmount': mCommission,
        });
      }
      rows.sort((a, b) =>
          ((b['netAmount'] as num?)?.toDouble() ?? 0)
              .compareTo((a['netAmount'] as num?)?.toDouble() ?? 0));

      if (!mounted) return;
      setState(() {
        _collected = collected;
        _spending = spending['total'] ?? 0;
        _inventorySpending = spending['inventory_total'] ?? 0;
        _utilitiesSpending = spending['utilities_total'] ?? 0;
        _commission = commission;
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

  double get _profit => _collected - _spending - _commission;

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

  Widget _breakdownRow(IconData icon, Color color, String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ),
          Text(Fmt.money(value),
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLang.tr('profitReport'))),
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
                      // Total profit for the selected month
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.trending_up,
                                    color: Colors.green, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppLang.tr('profit'),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                Fmt.money(_profit),
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Breakdown card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLang.tr('summary'),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 12),
                              _breakdownRow(
                                  Icons.payments_outlined,
                                  Colors.indigo,
                                  AppLang.tr('collected'),
                                  _collected),
                              _breakdownRow(
                                  Icons.shopping_cart_outlined,
                                  Colors.orange,
                                  AppLang.tr('inventorySpending'),
                                  _inventorySpending),
                              _breakdownRow(
                                  Icons.bolt_outlined,
                                  Colors.amber,
                                  AppLang.tr('utilitiesSpending'),
                                  _utilitiesSpending),
                              _breakdownRow(
                                  Icons.percent,
                                  AppColors.lightBlue,
                                  AppLang.tr('commission'),
                                  _commission),
                              const Divider(height: 24),
                              _breakdownRow(
                                  Icons.trending_up,
                                  Colors.green,
                                  AppLang.tr('profit'),
                                  _profit),
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
                          final net =
                              (row['netAmount'] as num?)?.toDouble() ?? 0;
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
                                      Fmt.money(net),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      '${AppLang.tr('commission')}: '
                                      '${Fmt.money(commission)}',
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