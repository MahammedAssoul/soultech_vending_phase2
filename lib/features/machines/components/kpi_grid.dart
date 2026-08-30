part of '../machine_details_page.dart';

class _KpiData {
  const _KpiData(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.title, required this.items});
  final String title;
  final List<_KpiData> items;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      ),
      Column(children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, size: 20, color: item.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label,
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(item.value,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800)),
                        ]),
                  ),
                ]),
              ),
            ),
          ),
      ]),
    ]);
  }
}

/// KPI builders used by the machine dashboard.
class _KpiSections {
  const _KpiSections._();

  static Widget today(
      BuildContext context, Machine machine, Map<String, double> today) {
    return _KpiGrid(
      title: AppLang.tr('today'),
      items: [
        _KpiData(AppLang.tr('todaySales'), Fmt.money(today['total_sales'] ?? 0),
            Icons.point_of_sale, AppColors.blue),
        _KpiData(
            AppLang.tr('transactions'),
            '${(today['transaction_count'] ?? 0).toInt()}',
            Icons.receipt_long_outlined,
            AppColors.navy),
        _KpiData(AppLang.tr('profit'), Fmt.money(today['total_profit'] ?? 0),
            Icons.trending_up, Colors.green),
        _KpiData(
            AppLang.tr('commission'),
            Fmt.money(
                (today['total_sales'] ?? 0) * machine.commissionPercent / 100),
            Icons.percent,
            Colors.orange),
      ],
    );
  }

  static Widget month(
      BuildContext context, Map<String, double> month, double monthCommission) {
    return _KpiGrid(
      title: AppLang.tr('thisMonth'),
      items: [
        _KpiData(
            AppLang.tr('thisMonthSales'),
            Fmt.money(month['total_sales'] ?? 0),
            Icons.point_of_sale,
            AppColors.blue),
        _KpiData(AppLang.tr('totalCost'), Fmt.money(month['total_cost'] ?? 0),
            Icons.shopping_cart_outlined, AppColors.navy),
        _KpiData(
            AppLang.tr('thisMonthProfit'),
            Fmt.money(month['total_profit'] ?? 0),
            Icons.trending_up,
            Colors.green),
        _KpiData(AppLang.tr('thisMonthCommission'), Fmt.money(monthCommission),
            Icons.percent, Colors.orange),
      ],
    );
  }

  static Widget cash(Map<String, double> cash) {
    final diff = cash['difference'] ?? 0;
    return _KpiGrid(
      title: AppLang.tr('cash'),
      items: [
        _KpiData(AppLang.tr('expectedCash'), Fmt.money(cash['expected'] ?? 0),
            Icons.account_balance_wallet_outlined, AppColors.blue),
        _KpiData(AppLang.tr('actualCash'), Fmt.money(cash['actual'] ?? 0),
            Icons.payments_outlined, AppColors.navy),
        _KpiData(
          AppLang.tr('difference'),
          Fmt.money(diff),
          diff == 0
              ? Icons.check_circle_outline
              : (diff > 0 ? Icons.trending_up : Icons.trending_down),
          diff == 0 ? Colors.grey : (diff > 0 ? Colors.green : Colors.red),
        ),
      ],
    );
  }

  static Widget inventory(Map<String, int> inventory) {
    return _KpiGrid(
      title: AppLang.tr('inventorySummary'),
      items: [
        _KpiData(AppLang.tr('products'), '${inventory['products'] ?? 0}',
            Icons.inventory_2_outlined, AppColors.blue),
        _KpiData(AppLang.tr('lowStock'), '${inventory['low_stock'] ?? 0}',
            Icons.warning_amber_outlined, Colors.orange),
        _KpiData(AppLang.tr('outOfStock'), '${inventory['out_of_stock'] ?? 0}',
            Icons.error_outline, Colors.red),
      ],
    );
  }
}
