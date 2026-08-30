part of '../inventory_page.dart';

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  (Color, IconData, String) _status() {
    if (product.isOutOfStock) {
      return (Colors.red, Icons.error_outline, AppLang.tr('outOfStock'));
    }
    if (product.isLowStock) {
      return (
        Colors.orange,
        Icons.warning_amber_outlined,
        AppLang.tr('lowStock')
      );
    }
    return (Colors.green, Icons.check_circle_outline, AppLang.tr('inStock'));
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _status();
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.inventory_2_outlined, color: AppColors.blue),
        ),
        title: Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${product.category.isEmpty ? AppLang.tr('uncategorized') : product.category} • '
          '${AppLang.tr('sellingPrice')} ${Fmt.money(product.sellingPrice)} • '
          '${AppLang.tr('stock')} ${product.currentStock}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        isThreeLine: false,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Chip(
            avatar: Icon(icon, size: 16, color: color),
            label: Text(label),
            labelStyle: TextStyle(color: color, fontSize: 12),
            backgroundColor: color.withValues(alpha: .1),
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: AppLang.tr('edit'),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: AppLang.tr('delete'),
          ),
        ]),
        onTap: onTap,
      ),
    );
  }
}
