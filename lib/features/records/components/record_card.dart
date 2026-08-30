part of '../records_page.dart';

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.machineName,
    required this.onTap,
    required this.onDelete,
  });

  final Object record;
  final String machineName;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final typeInfo = _typeInfo(record);
    final (title, amountLine) = _titleAmount(context, record);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: typeInfo.color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(typeInfo.icon, size: 22, color: typeInfo.color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${_formatDate(record)}\n$machineName • $amountLine',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        isThreeLine: true,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onTap,
            tooltip: AppLang.tr('edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
            tooltip: AppLang.tr('delete'),
          ),
        ]),
        onTap: onTap,
      ),
    );
  }

  ({IconData icon, Color color}) _typeInfo(Object r) => switch (r) {
        SaleRecord _ => (icon: Icons.point_of_sale, color: AppColors.blue),
        RestockingRecord _ => (
            icon: Icons.inventory_2_outlined,
            color: Colors.green
          ),
        ChangeAddedRecord _ => (
            icon: Icons.savings_outlined,
            color: Colors.orange
          ),
        CashReadingRecord _ => (
            icon: Icons.local_atm_outlined,
            color: Colors.purple
          ),
        CashCollectionRecord _ => (
            icon: Icons.payments_outlined,
            color: Colors.indigo
          ),
        ReconciliationRecord _ => (
            icon: Icons.balance_outlined,
            color: Colors.teal
          ),
        _ => (icon: Icons.receipt_outlined, color: Colors.grey),
      };

  (String, String) _titleAmount(BuildContext context, Object r) => switch (r) {
        SaleRecord s => (
            AppLang.tr('sales'),
            '${s.quantity} × ${AppLang.tr('currency')}${s.unitPrice.toStringAsFixed(2)} = ${AppLang.tr('currency')}${s.totalAmount.toStringAsFixed(2)}'
          ),
        RestockingRecord s => (
            AppLang.tr('restocking'),
            '${s.quantity} × ${AppLang.tr('currency')}${s.unitCost.toStringAsFixed(2)} = ${AppLang.tr('currency')}${s.totalCost.toStringAsFixed(2)}'
          ),
        ChangeAddedRecord s => (
            AppLang.tr('changeAdded'),
            '${AppLang.tr('currency')}${s.amount.toStringAsFixed(2)}'
          ),
        CashReadingRecord s => (
            AppLang.tr('cashReading'),
            '${AppLang.tr('currency')}${s.readingAmount.toStringAsFixed(2)}'
          ),
        CashCollectionRecord s => (
            AppLang.tr('cashCollection'),
            '${AppLang.tr('collectedAmount')} ${AppLang.tr('currency')}${s.collectedAmount.toStringAsFixed(2)}'
          ),
        ReconciliationRecord s => (
            AppLang.tr('reconciliation'),
            '${AppLang.tr('currency')}${s.actualAmount.toStringAsFixed(2)} / ${AppLang.tr('currency')}${s.expectedAmount.toStringAsFixed(2)}'
          ),
        _ => ('', ''),
      };

  String _formatDate(Object r) {
    final d = switch (r) {
      SaleRecord s => s.date,
      RestockingRecord s => s.date,
      ChangeAddedRecord s => s.date,
      CashReadingRecord s => s.date,
      CashCollectionRecord s => s.date,
      ReconciliationRecord s => s.date,
      _ => DateTime.now(),
    };
    return DateFormat('dd/MM/yyyy').format(d);
  }
}
