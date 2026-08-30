import 'package:flutter/material.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/theme/app_theme.dart';
import 'package:soultech_vending/core/utils/format.dart';
import 'package:soultech_vending/data/models/product.dart';
import 'package:soultech_vending/data/repositories/product_repository.dart';
import 'package:soultech_vending/features/inventory/product_form_page.dart';

part 'components/product_card.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _repo = ProductRepository();
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _products = await _repo.getAll(includeInactive: true);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _edit([Product? p]) async {
    final changed = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => ProductFormPage(product: p)));
    if (changed == true) _load();
  }

  Future<void> _delete(Product p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLang.tr('delete')),
        content: Text(AppLang.tr('confirmDeleteProduct')),
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
    if (p.id == null) return;
    // Soft delete: deactivate instead of hard-deleting products with history.
    await _repo.deactivate(p.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(AppLang.tr('inventory')),
          actions: [
            IconButton(
              onPressed: () => _edit(),
              icon: const Icon(Icons.add),
              tooltip: AppLang.tr('addProduct'),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(),
          icon: const Icon(Icons.add),
          label: Text(AppLang.tr('addProduct')),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: _products.isEmpty
                    ? ListView(children: [
                        const SizedBox(height: 180),
                        Center(child: Text(AppLang.tr('noProductsYet'))),
                      ])
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final p = _products[i];
                          return _ProductCard(
                            product: p,
                            onTap: () => _edit(p),
                            onEdit: () => _edit(p),
                            onDelete: () => _delete(p),
                          );
                        },
                      ),
              ),
      );
}
