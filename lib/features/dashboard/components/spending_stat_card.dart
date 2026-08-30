part of '../dashboard_page.dart';

/// Dashboard card showing "Total Spending This Month" with the inventory /
/// utilities breakdown. Matches the existing _StatCard visual style.
class _SpendingStatCard extends StatelessWidget {
  const _SpendingStatCard({
    required this.total,
    required this.inventory,
    required this.utilities,
  });

  final double total;
  final double inventory;
  final double utilities;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined,
                      color: Colors.red, size: 20),
                ),
                const Spacer(),
                Text(Fmt.money(total),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 10),
              Text(AppLang.tr('totalSpendingThisMonth'),
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: _mini(
                    AppLang.tr('inventorySpending'),
                    inventory,
                    Colors.red.shade300,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _mini(
                    AppLang.tr('utilitiesSpending'),
                    utilities,
                    Colors.orange,
                  ),
                ),
              ]),
            ],
          ),
        ),
      );

  Widget _mini(String label, double value, Color color) => Row(children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
          ),
        ),
        Text(Fmt.money(value),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ]);
}
