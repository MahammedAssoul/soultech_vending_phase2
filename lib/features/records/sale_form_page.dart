import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/models/product.dart';
import 'package:soultech_vending/data/models/sale_record.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';
import 'package:soultech_vending/data/repositories/product_repository.dart';
import 'package:soultech_vending/data/repositories/sale_repository.dart';

class SaleFormPage extends StatefulWidget {
  const SaleFormPage({super.key, this.sale, this.preselectedMachineId});
  final SaleRecord? sale;
  final int? preselectedMachineId;

  @override
  State<SaleFormPage> createState() => _SaleFormPageState();
}

class _SaleFormPageState extends State<SaleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  final _unitPriceCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  List<Machine> _machines = [];
  List<Product> _products = [];
  Machine? _selectedMachine;
  Product? _selectedProduct;
  DateTime _date = DateTime.now();
  bool _loading = true;

  double get _totalAmount =>
      (double.tryParse(_qtyCtrl.text) ?? 0) *
      (double.tryParse(_unitPriceCtrl.text) ?? 0);
  double get _totalCost =>
      (double.tryParse(_qtyCtrl.text) ?? 0) *
      (double.tryParse(_costPriceCtrl.text) ?? 0);
  double get _profit => _totalAmount - _totalCost;

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.sale != null) {
      final s = widget.sale!;
      _qtyCtrl.text = s.quantity.toString();
      _unitPriceCtrl.text = s.unitPrice.toString();
      _costPriceCtrl.text = s.costPrice.toString();
      _notesCtrl.text = s.notes;
      _date = s.date;
    }
    _qtyCtrl.addListener(() => setState(() {}));
    _unitPriceCtrl.addListener(() => setState(() {}));
    _costPriceCtrl.addListener(() => setState(() {}));
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
        if (widget.sale != null) {
          _selectedMachine = _machines.firstWhere(
            (m) => m.id == widget.sale!.machineId,
            orElse: () => _machines.first,
          );
          if (widget.sale!.productId != null) {
            try {
              _selectedProduct = _products.firstWhere(
                (p) => p.id == widget.sale!.productId,
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
    _unitPriceCtrl.dispose();
    _costPriceCtrl.dispose();
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
          const SnackBar(content: Text('Please select a machine')));
      return;
    }
    final record = SaleRecord.calculated(
      id: widget.sale?.id,
      machineId: _selectedMachine!.id!,
      productId: _selectedProduct?.id,
      productName: _selectedProduct?.name ?? '',
      quantity: double.tryParse(_qtyCtrl.text) ?? 1,
      unitPrice: double.tryParse(_unitPriceCtrl.text) ?? 0,
      costPrice: double.tryParse(_costPriceCtrl.text) ?? 0,
      date: _date,
      notes: _notesCtrl.text.trim(),
    );
    await SaleRepository().save(record);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar:
            AppBar(title: Text(widget.sale == null ? 'Add Sale' : 'Edit Sale')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Machine dropdown
                    DropdownButtonFormField<Machine>(
                      initialValue: _selectedMachine,
                      decoration: const InputDecoration(labelText: 'Machine *'),
                      items: _machines
                          .map((m) =>
                              DropdownMenuItem(value: m, child: Text(m.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedMachine = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    // Product dropdown
                    DropdownButtonFormField<Product>(
                      initialValue: _selectedProduct,
                      decoration: const InputDecoration(labelText: 'Product'),
                      items: [
                        const DropdownMenuItem<Product>(
                            value: null, child: Text('— No product —')),
                        ..._products.map((p) =>
                            DropdownMenuItem(value: p, child: Text(p.name))),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _selectedProduct = v;
                          if (v != null) {
                            _unitPriceCtrl.text =
                                v.sellingPrice.toStringAsFixed(2);
                            _costPriceCtrl.text =
                                v.costPrice.toStringAsFixed(2);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _qtyCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Quantity *'),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _unitPriceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Unit Price *', prefixText: 'LYD '),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n < 0) return 'Must be ≥ 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _costPriceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Cost Price', prefixText: 'LYD '),
                    ),
                    const SizedBox(height: 14),
                    // Auto-calculated summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(children: [
                        _calcRow('Total Sale',
                            'LYD ${_totalAmount.toStringAsFixed(2)}'),
                        _calcRow('Total Cost',
                            'LYD ${_totalCost.toStringAsFixed(2)}'),
                        const Divider(),
                        _calcRow(
                          'Profit',
                          'LYD ${_profit.toStringAsFixed(2)}',
                          color: _profit >= 0 ? Colors.green : Colors.red,
                        ),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date'),
                        child: Text(DateFormat('dd/MM/yyyy').format(_date)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _notesCtrl,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Sale'),
                      style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52)),
                    ),
                  ],
                ),
              ),
      );

  Widget _calcRow(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: color ?? Colors.black87)),
        ]),
      );
}
