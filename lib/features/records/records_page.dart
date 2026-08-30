import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/theme/app_theme.dart';
import 'package:soultech_vending/data/models/cash_collection_record.dart';
import 'package:soultech_vending/data/models/change_added_record.dart';
import 'package:soultech_vending/data/models/cash_reading_record.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/models/reconciliation_record.dart';
import 'package:soultech_vending/data/models/restocking_record.dart';
import 'package:soultech_vending/data/models/sale_record.dart';
import 'package:soultech_vending/data/repositories/app_database.dart';
import 'package:soultech_vending/data/repositories/cash_collection_repository.dart';
import 'package:soultech_vending/data/repositories/change_added_repository.dart';
import 'package:soultech_vending/data/repositories/cash_reading_repository.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';
import 'package:soultech_vending/data/repositories/reconciliation_repository.dart';
import 'package:soultech_vending/data/repositories/restocking_repository.dart';
import 'package:soultech_vending/data/repositories/sale_repository.dart';
import 'package:soultech_vending/features/records/cash_collection_form_page.dart';
import 'package:soultech_vending/features/records/change_added_form_page.dart';
import 'package:soultech_vending/features/records/cash_reading_form_page.dart';
import 'package:soultech_vending/features/records/reconciliation_form_page.dart';
import 'package:soultech_vending/features/records/record_type_selector.dart';
import 'package:soultech_vending/features/records/restocking_form_page.dart';
import 'package:soultech_vending/features/records/sale_form_page.dart';

part 'components/record_card.dart';
part 'components/record_filters.dart';
part 'extensions/load_records.dart';

/// Global records page: shows operational records across all machines with
/// filter by type, machine and date range, plus Add / Edit / Delete.
class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});
  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  List<Machine> _machines = [];
  int? _machineId;
  String _type = 'all';
  DateTime? _from;
  DateTime? _to;
  bool _loading = true;
  String? _error;

  List<Object> _records = [];

  final _saleRepo = SaleRepository();
  final _restockRepo = RestockingRepository();
  final _changeRepo = ChangeAddedRepository();
  final _cashRepo = CashReadingRepository();
  final _reconRepo = ReconciliationRepository();
  final _collectionRepo = CashCollectionRepository();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _machines = await MachineRepository().getAll();
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _load() async {
    try {
      final db = await AppDatabase.instance.db;
      final saleRows = await db.query(
        'sale_records',
        where: _whereClause('machine_id', 'date'),
        whereArgs: _args('machine_id', 'date'),
        orderBy: 'date DESC, id DESC',
      );
      final sales = saleRows.map(SaleRecord.fromMap).toList();

      final restocks = await _restockRepo.getAll(
          machineId: _machineId, from: _from, to: _to);
      final changes =
          await _changeRepo.getAll(machineId: _machineId, from: _from, to: _to);
      final cashings =
          await _cashRepo.getAll(machineId: _machineId, from: _from, to: _to);
      final collections = await _collectionRepo.getAll(
          machineId: _machineId, from: _from, to: _to);
      final reconciliations =
          await _reconRepo.getAll(machineId: _machineId, from: _from, to: _to);

      // Apply type filter for non-sale records
      final filterByType = <Object>[
        if (_type == 'all' || _type == RecordType.restocking.name) ...restocks,
        if (_type == 'all' || _type == RecordType.changeAdded.name) ...changes,
        if (_type == 'all' || _type == RecordType.cashReading.name) ...cashings,
        if (_type == 'all' || _type == RecordType.cashCollection.name)
          ...collections,
        if (_type == 'all' || _type == RecordType.reconciliation.name)
          ...reconciliations,
      ];

      if (!mounted) return;
      setState(() {
        _records = [...sales, ...filterByType];
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

  String _machineName(int? id) {
    for (final m in _machines) {
      if (m.id == id) return m.name;
    }
    return AppLang.tr('allMachines');
  }

  int? _machineIdOf(Object record) => switch (record) {
        SaleRecord r => r.machineId,
        RestockingRecord r => r.machineId,
        ChangeAddedRecord r => r.machineId,
        CashReadingRecord r => r.machineId,
        CashCollectionRecord r => r.machineId,
        ReconciliationRecord r => r.machineId,
        _ => null,
      };

  Future<void> _addRecord() async {
    final type = await showRecordTypeSelector(context);
    if (type == null || !mounted) return;
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => switch (type) {
            RecordType.sale => const SaleFormPage(),
            RecordType.restocking => const RestockingFormPage(),
            RecordType.changeAdded => const ChangeAddedFormPage(),
            RecordType.cashReading => const CashReadingFormPage(),
            RecordType.cashCollection => const CashCollectionFormPage(),
            RecordType.reconciliation => const ReconciliationFormPage(),
          },
        ));
    _load();
  }

  Future<void> _edit(Object record) async {
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
            _ => SaleFormPage(), // unreachable fallback
          },
        ));
    _load();
  }

  Future<void> _delete(Object record) async {
    final confirmed = await _confirm(AppLang.tr('confirmDelete'));
    if (!confirmed) return;
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

  Future<bool> _confirm(String message) async {
    if (!mounted) return false;
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLang.tr('delete')),
        content: Text(message),
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
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLang.tr('records')),
        actions: [
          IconButton(
            onPressed: _addRecord,
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: AppLang.tr('filter'),
          ),
        ],
      ),
      body: Column(children: [
        _RecordFilters(
          type: _type,
          machineId: _machineId,
          machines: _machines,
          from: _from,
          to: _to,
          onTypeChanged: (v) {
            setState(() => _type = v);
            _load();
          },
          onMachineChanged: (v) {
            setState(() => _machineId = v);
            _load();
          },
          onFromChanged: (d) => setState(() => _from = d),
          onToChanged: (d) => setState(() => _to = d),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
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
                  : _records.isEmpty
                      ? Center(child: Text(AppLang.tr('noRecordsYet')))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: _records.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final r = _records[i];
                              return _RecordCard(
                                record: r,
                                machineName: _machineName(_machineIdOf(r)),
                                onTap: () => _edit(r),
                                onDelete: () => _delete(r),
                              );
                            },
                          ),
                        ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecord,
        icon: const Icon(Icons.add),
        label: Text(AppLang.tr('addRecord')),
      ),
    );
  }
}
