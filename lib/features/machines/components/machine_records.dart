part of '../machine_details_page.dart';

class _RecordsFilterBar extends StatelessWidget {
  const _RecordsFilterBar({
    required this.typeFilter,
    required this.onChanged,
  });

  final String typeFilter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        ListTile(
          leading: const Icon(Icons.filter_list),
          title: Text(AppLang.tr('recordsFilter')),
          trailing: DropdownButton<String>(
            value: typeFilter,
            underline: const SizedBox.shrink(),
            items: [
              DropdownMenuItem(value: 'all', child: Text(AppLang.tr('all'))),
              ...RecordType.values.map(
                  (t) => DropdownMenuItem(value: t.name, child: Text(t.label))),
            ],
            onChanged: (v) => onChanged(v!),
          ),
        ),
        const Divider(height: 1),
      ]),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile(
      {required this.record, required this.onTap, required this.onDelete});
  final Object record;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  ({IconData icon, Color color, String title, String amount}) _info() =>
      switch (record) {
        SaleRecord s => (
            icon: Icons.point_of_sale,
            color: AppColors.blue,
            title: AppLang.tr('sales'),
            amount: Fmt.money(s.totalAmount),
          ),
        RestockingRecord s => (
            icon: Icons.inventory_2_outlined,
            color: Colors.green,
            title: AppLang.tr('restocking'),
            amount: Fmt.money(s.totalCost),
          ),
        ChangeAddedRecord s => (
            icon: Icons.savings_outlined,
            color: Colors.orange,
            title: AppLang.tr('changeAdded'),
            amount: Fmt.money(s.amount),
          ),
        CashReadingRecord s => (
            icon: Icons.local_atm_outlined,
            color: Colors.purple,
            title: AppLang.tr('cashReading'),
            amount: Fmt.money(s.readingAmount),
          ),
        CashCollectionRecord s => (
            icon: Icons.payments_outlined,
            color: Colors.indigo,
            title: AppLang.tr('cashCollection'),
            amount: Fmt.money(s.collectedAmount),
          ),
        ReconciliationRecord s => (
            icon: Icons.balance_outlined,
            color: Colors.teal,
            title: AppLang.tr('reconciliation'),
            amount: Fmt.money(s.difference),
          ),
        _ => (
            icon: Icons.receipt_outlined,
            color: Colors.grey,
            title: '',
            amount: ''
          ),
      };

  DateTime _date() => switch (record) {
        SaleRecord s => s.date,
        RestockingRecord s => s.date,
        ChangeAddedRecord s => s.date,
        CashReadingRecord s => s.date,
        CashCollectionRecord s => s.date,
        ReconciliationRecord s => s.date,
        _ => DateTime(2000),
      };

  @override
  Widget build(BuildContext context) {
    final info = _info();
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: info.color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(info.icon, size: 20, color: info.color),
        ),
        title: Text(info.title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(_date()),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(info.amount,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: onTap,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: onDelete,
          ),
        ]),
        onTap: onTap,
      ),
    );
  }
}
