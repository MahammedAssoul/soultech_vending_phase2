import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/utils/format.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/models/product.dart';
import 'package:soultech_vending/data/models/restocking_record.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';
import 'package:soultech_vending/data/repositories/product_repository.dart';
import 'package:soultech_vending/data/repositories/restocking_repository.dart';

class RestockingFormPage extends StatefulWidget {
  const RestockingFormPage({super.key, this.record, this.preselectedMachineId});
  final RestockingRecord? record;
  final int? preselectedMachineId;

  @override
  State<RestockingFormPage> createState() => _RestockingFormPageState();
}

class _RestockingFormPageState extends State<RestockingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  final _unitCostCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  List<Machine> _machines = [];
  List<Product> _products = [];
  Machine? _selectedMachine;
  Product? _selectedProduct;
  DateTime _date = DateTime.now();
  bool _loading = true;

  double get _totalCost =>
      (double.tryParse(_qtyCtrl.text) ?? 0) *
      (double.tryParse(_unitCostCtrl.text) ?? 0);

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.record != null) {
      final r = widget.record!;
      _qtyCtrl.text = r.quantity.toString();
      _unitCostCtrl.text = r.unitCost.toString();
      _notesCtrl.text = r.notes;
      _date = r.date;
    }
    _qtyCtrl.addListener(() => setState(() {}));
    _unitCostCtrl.addListener(() => setState(() {}));
  }

  Future<void> _load() async {
    _machines = await MachineRepository().getAll();
    _products = await ProductRepository().getAll();
    if (mounted) {
      setState(() {
        _loading = false;
        if (widget.preselectedMachineId != null) {
          _selectedMachine = _machines.firstWhere(
            (m) => m.id == widget.preselectedMachineId,
            orElse: () => _machines.first,
          );
        }
        if (widget.record != null) {
          _selectedMachine = _machines.firstWhere(
            (m) => m.id == widget.record!.machineId,
            orElse: () => _machines.first,
          );
          if (widget.record!.productId != null) {
            try {
              _selectedProduct = _products.firstWhere(
                (p) => p.id == widget.record!.productId,
              );
            } catch (_) {}
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _unitCostCtrl.dispose();
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
    if (_selectedMachine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLang.tr('pleaseSelectMachine'))));
      return;
    }
    final record = RestockingRecord.calculated(
      id: widget.record?.id,
      machineId: _selectedMachine!.id!,
      productId: _selectedProduct?.id,
      productName: _selectedProduct?.name ?? '',
      quantity: double.tryParse(_qtyCtrl.text) ?? 0,
      unitCost: double.tryParse(_unitCostCtrl.text) ?? 0,
      date: _date,
      notes: _notesCtrl.text.trim(),
    );
    // Load previous record (if editing) so inventory can be adjusted.
    RestockingRecord? previous;
    if (widget.record?.id != null) {
      previous = await RestockingRepository().getById(widget.record!.id!);
    }
    await RestockingRepository().save(record, previous: previous);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(widget.record == null
                ? AppLang.tr('addRestocking')
                : AppLang.tr('editRestocking'))),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    DropdownButtonFormField<Machine>(
                      initialValue: _selectedMachine,
                      decoration:
                          InputDecoration(labelText: AppLang.tr('machine')),
                      items: _machines
                          .map((m) =>
                              DropdownMenuItem(value: m, child: Text(m.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedMachine = v),
                      validator: (v) =>
                          v == null ? AppLang.tr('required') : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<Product>(
                      initialValue: _selectedProduct,
                      decoration:
                          InputDecoration(labelText: AppLang.tr('product')),
                      items: [
                        DropdownMenuItem<Product>(
                            value: null, child: Text(AppLang.tr('noProduct'))),
                        ..._products.map((p) =>
                            DropdownMenuItem(value: p, child: Text(p.name))),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _selectedProduct = v;
                          if (v != null) {
                            _unitCostCtrl.text = v.costPrice.toStringAsFixed(2);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _qtyCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText: '${AppLang.tr('quantity')} *'),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n <= 0) {
                          return AppLang.tr('mustBeGreaterThanZero');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _unitCostCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText: '${AppLang.tr('unitCost')} *',
                          prefixText: '${AppLang.tr('currency')} '),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n < 0) {
                          return AppLang.tr('mustBeNonNegative');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(children: [
                        Text(AppLang.tr('totalCost'),
                            style: TextStyle(color: Colors.grey.shade600)),
                        const Spacer(),
                        Text(Fmt.money(_totalCost),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.green)),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration:
                            InputDecoration(labelText: AppLang.tr('date')),
                        child: Text(DateFormat('dd/MM/yyyy').format(_date)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _notesCtrl,
                      decoration:
                          InputDecoration(labelText: AppLang.tr('notes')),
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
