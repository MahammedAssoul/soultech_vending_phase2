import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/models/spending_record.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';
import 'package:soultech_vending/data/repositories/spending_repository.dart';

/// Form for adding/editing a spending record.
///
/// Shows inventory fields (supplier) or utilities fields (utility type)
/// depending on [type].
class SpendingFormPage extends StatefulWidget {
  const SpendingFormPage({super.key, this.record, this.type});
  final SpendingRecord? record;

  /// Required when adding; ignored when [record] is provided.
  final SpendingType? type;

  @override
  State<SpendingFormPage> createState() => _SpendingFormPageState();
}

class _SpendingFormPageState extends State<SpendingFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _supplierCtrl;
  late final TextEditingController _refCtrl;
  late final TextEditingController _notesCtrl;

  late SpendingType _type;
  late DateTime _date;
  late String _utilityType;
  int? _machineId;

  List<Machine> _machines = [];

  static const _utilityOptions = [
    'electricity',
    'water',
    'internet',
    'fuel',
    'transportation',
    'maintenance',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _amountCtrl =
        TextEditingController(text: widget.record?.amount.toString() ?? '');
    _descriptionCtrl =
        TextEditingController(text: widget.record?.description ?? '');
    _supplierCtrl = TextEditingController(text: widget.record?.supplier ?? '');
    _refCtrl =
        TextEditingController(text: widget.record?.referenceNumber ?? '');
    _notesCtrl = TextEditingController(text: widget.record?.notes ?? '');
    _type = widget.record?.type ?? widget.type ?? SpendingType.inventory;
    _date = widget.record?.date ?? DateTime.now();
    _utilityType = widget.record?.utilityType ?? '';
    _machineId = widget.record?.machineId;
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    _machines = await MachineRepository().getAll();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    _supplierCtrl.dispose();
    _refCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final record = SpendingRecord.now(
      id: widget.record?.id,
      type: _type,
      date: _date,
      amount: double.tryParse(_amountCtrl.text) ?? 0,
      description: _descriptionCtrl.text.trim(),
      machineId: _machineId,
      supplier:
          _type == SpendingType.inventory ? _supplierCtrl.text.trim() : '',
      utilityType: _type == SpendingType.utilities ? _utilityType : '',
      referenceNumber: _refCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );
    await SpendingRepository().save(record);
    if (mounted) Navigator.pop(context, true);
  }

  String? _amountValidator(String? v) {
    final n = double.tryParse(v ?? '');
    if (n == null || n <= 0) return AppLang.tr('mustBeGreaterThanZero');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.record == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _type == SpendingType.inventory
              ? (isNew
                  ? AppLang.tr('addInventorySpending')
                  : AppLang.tr('editInventorySpending'))
              : (isNew
                  ? AppLang.tr('addUtilitiesSpending')
                  : AppLang.tr('editUtilitiesSpending')),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Type selector (only when adding)
            if (isNew)
              DropdownButtonFormField<SpendingType>(
                initialValue: _type,
                decoration:
                    InputDecoration(labelText: AppLang.tr('spendingType')),
                items: [
                  DropdownMenuItem(
                    value: SpendingType.inventory,
                    child: Text(AppLang.tr('inventorySpending')),
                  ),
                  DropdownMenuItem(
                    value: SpendingType.utilities,
                    child: Text(AppLang.tr('utilitiesSpending')),
                  ),
                ],
                onChanged: (v) =>
                    setState(() => _type = v ?? SpendingType.inventory),
              ),
            if (isNew) const SizedBox(height: 14),
            // Date
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(labelText: AppLang.tr('date')),
                child: Text(DateFormat('dd/MM/yyyy').format(_date)),
              ),
            ),
            const SizedBox(height: 14),
            // Amount
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '${AppLang.tr('amount')} *',
                prefixText: '${AppLang.tr('currency')} ',
              ),
              validator: _amountValidator,
            ),
            const SizedBox(height: 14),
            // Utilities: utility type dropdown
            if (_type == SpendingType.utilities) ...[
              DropdownButtonFormField<String>(
                initialValue: _utilityType.isEmpty ? null : _utilityType,
                decoration: InputDecoration(
                    labelText: '${AppLang.tr('utilityType')} *'),
                items: [
                  for (final u in _utilityOptions)
                    DropdownMenuItem(value: u, child: Text(AppLang.tr(u))),
                ],
                onChanged: (v) => setState(() => _utilityType = v ?? ''),
                validator: (v) =>
                    (v == null || v.isEmpty) ? AppLang.tr('required') : null,
              ),
              const SizedBox(height: 14),
            ],
            // Inventory: supplier
            if (_type == SpendingType.inventory) ...[
              TextFormField(
                controller: _supplierCtrl,
                decoration: InputDecoration(labelText: AppLang.tr('supplier')),
              ),
              const SizedBox(height: 14),
            ],
            // Description
            TextFormField(
              controller: _descriptionCtrl,
              decoration: InputDecoration(labelText: AppLang.tr('description')),
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            // Machine (optional)
            DropdownButtonFormField<int?>(
              initialValue: _machineId,
              decoration: InputDecoration(labelText: AppLang.tr('machine')),
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
              onChanged: (v) => setState(() => _machineId = v),
            ),
            const SizedBox(height: 14),
            // Reference number
            TextFormField(
              controller: _refCtrl,
              decoration:
                  InputDecoration(labelText: AppLang.tr('referenceNumber')),
            ),
            const SizedBox(height: 14),
            // Notes
            TextFormField(
              controller: _notesCtrl,
              decoration: InputDecoration(labelText: AppLang.tr('notes')),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(AppLang.tr('save')),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
            ),
          ],
        ),
      ),
    );
  }
}
