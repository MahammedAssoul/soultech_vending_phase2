import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/theme/app_theme.dart';
import 'package:soultech_vending/core/utils/format.dart';
import 'package:soultech_vending/core/widgets/empty_state.dart';
import 'package:soultech_vending/data/models/cash_collection_record.dart';
import 'package:soultech_vending/data/models/change_added_record.dart';
import 'package:soultech_vending/data/models/cash_reading_record.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/models/reconciliation_record.dart';
import 'package:soultech_vending/data/models/restocking_record.dart';
import 'package:soultech_vending/data/models/sale_record.dart';
import 'package:soultech_vending/data/repositories/cash_collection_repository.dart';
import 'package:soultech_vending/data/repositories/cash_reading_repository.dart';
import 'package:soultech_vending/data/repositories/change_added_repository.dart';
import 'package:soultech_vending/data/repositories/product_repository.dart';
import 'package:soultech_vending/data/repositories/reconciliation_repository.dart';
import 'package:soultech_vending/data/repositories/restocking_repository.dart';
import 'package:soultech_vending/data/repositories/sale_repository.dart';
import 'package:soultech_vending/features/records/cash_collection_form_page.dart';
import 'package:soultech_vending/features/records/change_added_form_page.dart';
import 'package:soultech_vending/features/records/cash_reading_form_page.dart';
import 'package:soultech_vending/features/records/record_type_selector.dart';
import 'package:soultech_vending/features/records/reconciliation_form_page.dart';
import 'package:soultech_vending/features/records/restocking_form_page.dart';
import 'package:soultech_vending/features/records/sale_form_page.dart';

part 'components/kpi_grid.dart';
part 'components/machine_charts.dart';
part 'components/machine_header.dart';
part 'components/machine_records.dart';
part 'extensions/load_machine_data.dart';

/// Machine Details — a per-machine dashboard with KPIs, charts, cash,
/// inventory and the machine's operational records.
class MachineDetailsPage extends StatefulWidget {
  const MachineDetailsPage({super.key, required this.machine});
  final Machine machine;

  @override
  State<MachineDetailsPage> createState() => _MachineDetailsPageState();
}

class _MachineDetailsPageState extends State<MachineDetailsPage> {
  bool _loading = true;
  String? _error;

  // KPI data
  Map<String, double> _today = {};
  Map<String, double> _month = {};
  Map<String, double> _cash = {};
  Map<String, int> _inventory = {};
  double _monthCommission = 0;
  double _monthCollected = 0;

  // Chart data
  List<FlSpot> _salesSpots = [];
  List<FlSpot> _profitSpots = [];
  List<FlSpot> _collectionSpots = [];

  // Records
  List<Object> _records = [];
  String _typeFilter = 'all';

  final _saleRepo = SaleRepository();
  final _restockRepo = RestockingRepository();
  final _changeRepo = ChangeAddedRepository();
  final _cashRepo = CashReadingRepository();
  final _reconRepo = ReconciliationRepository();
  final _collectionRepo = CashCollectionRepository();
  final _productRepo = ProductRepository();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final id = widget.machine.id!;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      final month =
          await _saleRepo.getSummary(machineId: id, from: monthStart, to: now);
      final today =
          await _saleRepo.getSummary(machineId: id, from: todayStart, to: now);
      final monthCommission = await _saleRepo.getTotalCommission(
          machineId: id, from: monthStart, to: now);

      // Cash section: last reconciliation
      final reconciliations = await _reconRepo.getAll(machineId: id);
      final lastRecon = reconciliations.isEmpty
          ? null
          : reconciliations.first; // sorted date DESC
      final cash = <String, double>{
        'expected': lastRecon?.expectedAmount ?? 0,
        'actual': lastRecon?.actualAmount ?? 0,
        'difference': lastRecon?.difference ?? 0,
      };

      // Inventory counts
      final status = await _productRepo.countMachineStockStatus(id);
      final products = await _productRepo.getAll();
      final inventory = <String, int>{
        'products': products.length,
        'low_stock': status['low_stock'] ?? 0,
        'out_of_stock': status['out_of_stock'] ?? 0,
      };

      // Charts: daily sales/profit for this month
      final byDay = await _saleRepo.getSalesByDay(
          machineId: id, from: monthStart, to: now);
      final salesSpots = <FlSpot>[];
      final profitSpots = <FlSpot>[];
      for (var i = 0; i < byDay.length; i++) {
        final d = DateTime.parse(byDay[i]['date'] as String);
        salesSpots.add(FlSpot(d.day.toDouble(),
            (byDay[i]['daily_sales'] as num?)?.toDouble() ?? 0));
        profitSpots.add(FlSpot(d.day.toDouble(),
            (byDay[i]['daily_profit'] as num?)?.toDouble() ?? 0));
      }

      // Cash collections: monthly total + daily chart
      final monthCollected = await _collectionRepo.getTotal(
          machineId: id, from: monthStart, to: now);
      final collByDay = await _collectionRepo.getCollectionsByDay(
          machineId: id, from: monthStart, to: now);
      final collSpots = <FlSpot>[];
      for (var i = 0; i < collByDay.length; i++) {
        final d = DateTime.parse(collByDay[i]['date'] as String);
        collSpots.add(FlSpot(d.day.toDouble(),
            (collByDay[i]['daily_collected'] as num?)?.toDouble() ?? 0));
      }

      // Records (all types for this machine)
      final sales = await _saleRepo.getAll(machineId: id);
      final restocks = await _restockRepo.getAll(machineId: id);
      final changes = await _changeRepo.getAll(machineId: id);
      final cashings = await _cashRepo.getAll(machineId: id);
      final collections = await _collectionRepo.getAll(machineId: id);
      final reconcil = await _reconRepo.getAll(machineId: id);
      final allRecords = <Object>[
        ...sales,
        ...restocks,
        ...changes,
        ...cashings,
        ...collections,
        ...reconcil
      ]..sort((a, b) => _dateOf(b).compareTo(_dateOf(a)));

      if (!mounted) return;
      setState(() {
        _today = today;
        _month = month;
        _cash = cash;
        _inventory = inventory;
        _monthCommission = monthCommission;
        _monthCollected = monthCollected;
        _salesSpots = salesSpots;
        _profitSpots = profitSpots;
        _collectionSpots = collSpots;
        _records = allRecords;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _addRecord() async {
    final type = await showRecordTypeSelector(context);
    if (type == null || !mounted) return;
    final id = widget.machine.id;
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => switch (type) {
            RecordType.sale => SaleFormPage(preselectedMachineId: id),
            RecordType.restocking =>
              RestockingFormPage(preselectedMachineId: id),
            RecordType.changeAdded =>
              ChangeAddedFormPage(preselectedMachineId: id),
            RecordType.cashReading =>
              CashReadingFormPage(preselectedMachineId: id),
            RecordType.cashCollection =>
              CashCollectionFormPage(preselectedMachineId: id),
            RecordType.reconciliation =>
              ReconciliationFormPage(preselectedMachineId: id),
          },
        ));
    _load();
  }

  Future<void> _editRecord(Object record) async {
    if (!mounted) return;
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => switch (record) {
            SaleRecord r => SaleFormPage(sale: r),
            RestockingRecord r => RestockingFormPage(record: r),
            ChangeAddedRecord r => ChangeAddedFormPage(record: r),
            CashReadingRecord r => CashReadingFormPage(record: r),
            CashCollectionRecord r => CashCollectionFormPage(record: r),
            ReconciliationRecord r => ReconciliationFormPage(record: r),
            _ => const SaleFormPage(),
          },
        ));
    _load();
  }

  Future<void> _deleteRecord(Object record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLang.tr('delete')),
        content: Text(AppLang.tr('confirmDelete')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLang.tr('cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLang.tr('delete'))),
        ],
      ),
    );
    if (confirmed != true) return;
    switch (record) {
      case SaleRecord r:
        await _saleRepo.delete(r.id!);
      case RestockingRecord r:
        await _restockRepo.delete(r.id!);
      case ChangeAddedRecord r:
        await _changeRepo.delete(r.id!);
      case CashReadingRecord r:
        await _cashRepo.delete(r.id!);
      case CashCollectionRecord r:
        await _collectionRepo.delete(r.id!);
      case ReconciliationRecord r:
        await _reconRepo.delete(r.id!);
    }
    _load();
  }

  Widget _buildRecords() {
    final filtered = _filteredRecords;
    if (filtered.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: AppLang.tr('noRecordsForMachine'),
            message: AppLang.tr('addRecord'),
          ),
        ),
      );
    }
    return Column(children: [
      for (final r in filtered)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _RecordTile(
            record: r,
            onTap: () => _editRecord(r),
            onDelete: () => _deleteRecord(r),
          ),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.machine;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        title: Text(m.name),
        actions: [
          IconButton(
            onPressed: _addRecord,
            icon: const Icon(Icons.add),
            tooltip: AppLang.tr('addRecord'),
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(
                    '${AppLang.tr('error')}: $_error',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      setState(() => _error = null);
                      _load();
                    },
                    child: Text(AppLang.tr('retry')),
                  ),
                ],
              ),
            )
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _HeaderCard(machine: m),
                      const SizedBox(height: 16),
                      if (width >= 900)
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child:
                                      _KpiSections.today(context, m, _today)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _KpiSections.month(
                                      context, _month, _monthCommission)),
                              const SizedBox(width: 12),
                              Expanded(child: _KpiSections.cash(_cash)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _KpiSections.inventory(_inventory)),
                            ])
                      else ...[
                        _KpiSections.today(context, m, _today),
                        const SizedBox(height: 12),
                        _KpiSections.month(context, _month, _monthCommission),
                        const SizedBox(height: 12),
                        _KpiSections.cash(_cash),
                        const SizedBox(height: 12),
                        _KpiSections.inventory(_inventory),
                      ],
                      const SizedBox(height: 16),
                      _MachineCharts(
                        salesSpots: _salesSpots,
                        profitSpots: _profitSpots,
                        collectionSpots: _collectionSpots,
                        monthCollected: _monthCollected,
                      ),
                      const SizedBox(height: 16),
                      _RecordsFilterBar(
                        typeFilter: _typeFilter,
                        onChanged: (v) => setState(() => _typeFilter = v),
                      ),
                      const SizedBox(height: 8),
                      _buildRecords(),
                    ],
                  ),
                ),
    );
  }
}
