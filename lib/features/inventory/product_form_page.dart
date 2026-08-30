import 'package:flutter/material.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/data/models/product.dart';
import 'package:soultech_vending/data/repositories/product_repository.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});
  final Product? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl =
      TextEditingController(text: widget.product?.name ?? '');
  late final _categoryCtrl =
      TextEditingController(text: widget.product?.category ?? '');
  late final _sellingCtrl = TextEditingController(
      text: widget.product?.sellingPrice.toString() ?? '');
  late final _costCtrl =
      TextEditingController(text: widget.product?.costPrice.toString() ?? '');
  late final _stockCtrl = TextEditingController(
      text: widget.product?.currentStock.toString() ?? '0');
  late final _minStockCtrl =
      TextEditingController(text: widget.product?.minStock.toString() ?? '5');
  late final _notesCtrl =
      TextEditingController(text: widget.product?.notes ?? '');
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _active = widget.product?.active ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _sellingCtrl.dispose();
    _costCtrl.dispose();
    _stockCtrl.dispose();
    _minStockCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? AppLang.tr('required') : null;

  String? _nonNegative(String? v) {
    final n = double.tryParse(v ?? '');
    if (n == null || n < 0) return AppLang.tr('mustBeNonNegative');
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final product = Product(
      id: widget.product?.id,
      name: _nameCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      sellingPrice: double.tryParse(_sellingCtrl.text) ?? 0,
      costPrice: double.tryParse(_costCtrl.text) ?? 0,
      currentStock: int.tryParse(_stockCtrl.text) ?? 0,
      minStock: int.tryParse(_minStockCtrl.text) ?? 5,
      lowStockThreshold: int.tryParse(_minStockCtrl.text) ?? 5,
      active: _active,
      notes: _notesCtrl.text.trim(),
    );
    await ProductRepository().save(product);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.product == null
              ? AppLang.tr('addProduct')
              : AppLang.tr('editProduct')),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration:
                    InputDecoration(labelText: AppLang.tr('productName')),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _categoryCtrl,
                decoration: InputDecoration(labelText: AppLang.tr('category')),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _sellingCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: AppLang.tr('sellingPrice'),
                  prefixText: '${AppLang.tr('currency')} ',
                ),
                validator: _nonNegative,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _costCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: AppLang.tr('costPrice'),
                  prefixText: '${AppLang.tr('currency')} ',
                ),
                validator: _nonNegative,
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: AppLang.tr('currentStock')),
                    validator: _nonNegative,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _minStockCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: AppLang.tr('minimumStock')),
                    validator: _nonNegative,
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(labelText: AppLang.tr('notes')),
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                title: Text(AppLang.tr('active')),
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
