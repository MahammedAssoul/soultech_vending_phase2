part of '../dashboard_page.dart';

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onCollectCash,
    required this.onSpending,
    required this.onReceipt,
    required this.onRecords,
    required this.onMachines,
    required this.onReports,
  });

  final VoidCallback onCollectCash;
  final VoidCallback onSpending;
  final VoidCallback onReceipt;
  final VoidCallback onRecords;
  final VoidCallback onMachines;
  final VoidCallback onReports;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLang.tr('quickActions'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onCollectCash,
                icon: const Icon(Icons.payments_outlined),
                label: Text(AppLang.tr('collectCash')),
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onSpending,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(AppLang.tr('spendingRecords')),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onReceipt,
                icon: const Icon(Icons.receipt_long_outlined),
                label: Text(AppLang.tr('salesReceipt')),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onRecords,
                icon: const Icon(Icons.list_alt_outlined),
                label: Text(AppLang.tr('records')),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onMachines,
                icon: const Icon(Icons.local_shipping_outlined),
                label: Text(AppLang.tr('machines')),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onReports,
                icon: const Icon(Icons.assessment_outlined),
                label: Text(AppLang.tr('reports')),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
              ),
            ],
          ),
        ),
      );
}
