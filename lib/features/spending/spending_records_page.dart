import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/theme/app_theme.dart';
import 'package:soultech_vending/core/utils/format.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/models/spending_record.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';
import 'package:soultech_vending/data/repositories/spending_repository.dart';
import 'package:soultech_vending/features/spending/spending_form_page.dart';

/// Spending Records page — inventory & utilities kept separate.
class SpendingRecordsPage extends StatefulWidget {
  const SpendingRecordsPage({super.key});
  @override
  State<SpendingRecordsPage> createState() => _SpendingRecordsPageState();
}

class _SpendingRecordsPageState extends State<SpendingRecordsPage> {
  final _repo = SpendingRepository();
  List<Machine> _machines = [];

  String _tab = 'all'; // all | inventory | utilities
  int? _machineId;
  DateTime? _from;
  DateTime? _to;

  bool _loading = true;
  String? _error;
  List<SpendingRecord> _records = [];
  Map<String, double> _totals = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _machines = await MachineRepository().getAll();
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final type = _tab == 'inventory'
          ? SpendingType.inventory
          : (_tab == 'utilities' ? SpendingType.utilities : null);
      final records = await _repo.getAll(
        type: type,
        machineId: _machineId,
        from: _from,
        to: _to,
      );
      final totals = await _repo.getTotals(
        machineId: _machineId,
        from: _from,
        to: _to,
      );
      if (!mounted) return;
      setState(() {
        _records = records;
        _totals = totals;
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

  String _machineName(int? id) {
    if (id == null) return AppLang.tr('allMachines');
    for (final m in _machines) {
      if (m.id == id) return m.name;
    }
    return '—';
  }

  Future<void> _add() async {
    final type = await showSpendingTypeSelector(context);
    if (type == null || !mounted) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SpendingFormPage(type: type),
      ),
    );
    if (changed == true) _load();
  }

  Future<void> _edit(SpendingRecord r) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => SpendingFormPage(record: r)),
    );
    if (changed == true) _load();
  }

  Future<void> _delete(SpendingRecord r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLang.tr('deleteSpending')),
        content: Text(AppLang.tr('confirmDeleteSpending')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLang.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLang.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (r.id != null) await _repo.delete(r.id!);
    _load();
  }

  Future<void> _pickFrom() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _from ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      setState(() => _from = d);
      _load();
    }
  }

  Future<void> _pickTo() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _to ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      setState(() => _to = d);
      _load();
    }
  }

  void _quick(String which) {
    final now = DateTime.now();
    switch (which) {
      case 'today':
        _from = now;
        _to = now;
      case 'week':
        _from = now.subtract(const Duration(days: 6));
        _to = now;
      case 'month':
        _from = DateTime(now.year, now.month, 1);
        _to = now;
      case 'lastMonth':
        _from = DateTime(now.year, now.month - 1, 1);
        _to = DateTime(now.year, now.month, 0);
      case 'year':
        _from = DateTime(now.year, 1, 1);
        _to = now;
      case 'custom':
        _from = null;
        _to = null;
    }
    setState(() {});
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLang.tr('spendingRecords')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: Text(AppLang.tr('addSpending')),
      ),
      body: Column(children: [
        // Tabs
        _tabs(),
        // Summary
        _summaryCard(),
        // Filters
        _filters(),
        const SizedBox(height: 8),
        // List
        Expanded(child: _list()),
      ]),
    );
  }

  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Expanded(
          child: _tabChip('all', AppLang.tr('all'), Icons.receipt_long_outlined,
              AppColors.blue),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _tabChip('inventory', AppLang.tr('inventorySpending'),
              Icons.inventory_2_outlined, Colors.green),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _tabChip('utilities', AppLang.tr('utilitiesSpending'),
              Icons.electrical_services, Colors.orange),
        ),
      ]),
    );
  }

  Widget _tabChip(String value, String label, IconData icon, Color color) {
    final selected = _tab == value;
    return InkWell(
      onTap: () {
        setState(() => _tab = value);
        _load();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: .12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected
                  ? color.withValues(alpha: .5)
                  : Colors.grey.shade300),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: selected ? color : Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? color : Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _summaryCard() {
    final shownInv =
        _tab == 'utilities' ? 0.0 : (_totals['inventory_total'] ?? 0);
    final shownUtil =
        _tab == 'inventory' ? 0.0 : (_totals['utilities_total'] ?? 0);
    final total = shownInv + shownUtil;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLang.tr('totalSpending'),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 4),
              Text(Fmt.money(total),
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800)),
              const Divider(height: 20),
              Row(children: [
                Expanded(
                  child: _summaryRow(
                      AppLang.tr('inventorySpending'), shownInv, Colors.green),
                ),
                Expanded(
                  child: _summaryRow(AppLang.tr('utilitiesSpending'), shownUtil,
                      Colors.orange),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double value, Color color) {
    return Row(children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ),
      Text(Fmt.money(value),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
    ]);
  }

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<int?>(
              initialValue: _machineId,
              decoration: InputDecoration(
                  labelText: AppLang.tr('machine'), isDense: true),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(AppLang.tr('allMachines')),
                ),
                ..._machines.map(
                  (m) => DropdownMenuItem<int?>(
                    value: m.id,
                    child: Text(m.name),
                  ),
                ),
              ],
              onChanged: (v) {
                setState(() => _machineId = v);
                _load();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: 'custom',
              decoration: InputDecoration(
                  labelText: AppLang.tr('quickFilters'), isDense: true),
              items: [
                for (final q in [
                  'today',
                  'week',
                  'month',
                  'lastMonth',
                  'year',
                  'custom'
                ])
                  DropdownMenuItem(value: q, child: Text(AppLang.tr(q))),
              ],
              onChanged: (v) => _quick(v!),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: _dateChip(AppLang.tr('fromDate'), _from, _pickFrom),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _dateChip(AppLang.tr('toDate'), _to, _pickTo),
          ),
        ]),
      ]),
    );
  }

  Widget _dateChip(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today, size: 16),
        ),
        child: Text(
          date == null ? '—' : DateFormat('dd/MM/yyyy').format(date),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _list() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('${AppLang.tr('error')}: $_error',
              textAlign: TextAlign.center),
        ),
      );
    }
    if (_records.isEmpty) {
      return Center(child: Text(AppLang.tr('noSpendingRecords')));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _records.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final r = _records[i];
          return _SpendingCard(
            record: r,
            machineName: _machineName(r.machineId),
            onTap: () => _edit(r),
            onDelete: () => _delete(r),
          );
        },
      ),
    );
  }
}

class _SpendingCard extends StatelessWidget {
  const _SpendingCard({
    required this.record,
    required this.machineName,
    required this.onTap,
    required this.onDelete,
  });

  final SpendingRecord record;
  final String machineName;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isInv = record.type == SpendingType.inventory;
    final color = isInv ? Colors.green : Colors.orange;
    final icon = isInv ? Icons.inventory_2_outlined : Icons.electrical_services;
    final subtitle = [
      if (isInv && record.supplier.isNotEmpty)
        AppLang.tr('supplier') + ': ' + record.supplier,
      if (!isInv && record.utilityType.isNotEmpty)
        AppLang.tr(record.utilityType),
      if (record.description.isNotEmpty) record.description,
      machineName,
    ].join(' • ');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          isInv
              ? AppLang.tr('inventorySpending')
              : AppLang.tr('utilitiesSpending'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        isThreeLine: true,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '- ${Fmt.money(record.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: color.shade700,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(record.date),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onTap,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
          ),
        ]),
        onTap: onTap,
      ),
    );
  }
}

/// Bottom sheet to pick a spending type before adding.
Future<SpendingType?> showSpendingTypeSelector(BuildContext context) {
  return showModalBottomSheet<SpendingType>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(AppLang.tr('addSpending'),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(AppLang.tr('selectSpendingType'),
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            _typeOption(SpendingType.inventory, Icons.inventory_2_outlined,
                Colors.green, ctx),
            const SizedBox(height: 10),
            _typeOption(SpendingType.utilities, Icons.electrical_services,
                Colors.orange, ctx),
          ],
        ),
      ),
    ),
  );
}

Widget _typeOption(
    SpendingType type, IconData icon, Color color, BuildContext ctx) {
  final label = type == SpendingType.inventory
      ? AppLang.tr('inventorySpending')
      : AppLang.tr('utilitiesSpending');
  final labelAr =
      type == SpendingType.inventory ? 'مصروفات المخزون' : 'مصروفات الخدمات';
  return InkWell(
    onTap: () => Navigator.pop(ctx, type),
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          Text(labelAr,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ]),
        const Spacer(),
        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
      ]),
    ),
  );
}
