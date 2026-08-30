part of '../reports_page.dart';

class _RestockingCard extends StatelessWidget {
  const _RestockingCard({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    if (data.restockingByMachine.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLang.tr('restockingReport'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined,
                      color: Colors.green),
                  title: Text(AppLang.tr('totalItemsRestocked')),
                  subtitle: Text(
                      Fmt.number(data.restockingSummary['total_qty'] ?? 0)),
                ),
              ),
              Expanded(
                child: ListTile(
                  leading: const Icon(Icons.attach_money, color: Colors.green),
                  title: Text(AppLang.tr('totalRestockingCost')),
                  subtitle: Text(
                      Fmt.money(data.restockingSummary['total_cost'] ?? 0)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _CashReportCard extends StatelessWidget {
  const _CashReportCard({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    if (data.cashSummary.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLang.tr('cashReport'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            DataTable(
              headingRowColor:
                  WidgetStatePropertyAll(AppColors.blue.withValues(alpha: .06)),
              columns: [
                DataColumn(label: Text(AppLang.tr('machine'))),
                DataColumn(label: Text(AppLang.tr('expected')), numeric: true),
                DataColumn(label: Text(AppLang.tr('actual')), numeric: true),
                DataColumn(
                    label: Text(AppLang.tr('difference')), numeric: true),
              ],
              rows: data.cashSummary.map((r) {
                final diff = (r['difference'] as num?)?.toDouble() ?? 0;
                return DataRow(cells: [
                  DataCell(Text('${r['machine_name']}')),
                  DataCell(Text(
                      Fmt.money((r['expected'] as num?)?.toDouble() ?? 0))),
                  DataCell(
                      Text(Fmt.money((r['actual'] as num?)?.toDouble() ?? 0))),
                  DataCell(Text(
                    Fmt.money(diff),
                    style: TextStyle(
                      color: diff == 0
                          ? Colors.grey
                          : (diff > 0 ? Colors.green : Colors.red),
                      fontWeight: FontWeight.w700,
                    ),
                  )),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfitCard extends StatelessWidget {
  const _ProfitCard({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLang.tr('profitReport'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ListTile(
                  leading: Icon(Icons.attach_money, color: AppColors.blue),
                  title: Text(AppLang.tr('revenue')),
                  subtitle: Text(Fmt.money(data.totalSales)),
                ),
              ),
              Expanded(
                child: ListTile(
                  leading:
                      Icon(Icons.shopping_cart_outlined, color: AppColors.navy),
                  title: Text(AppLang.tr('productCost')),
                  subtitle: Text(Fmt.money(data.totalCost)),
                ),
              ),
            ]),
            const Divider(),
            Row(children: [
              Expanded(
                child: ListTile(
                  leading: Icon(Icons.trending_up, color: Colors.green),
                  title: Text(AppLang.tr('grossProfit')),
                  subtitle: Text(Fmt.money(data.grossProfit)),
                ),
              ),
              Expanded(
                child: ListTile(
                  leading: Icon(Icons.percent, color: Colors.orange),
                  title: Text(AppLang.tr('totalCommission')),
                  subtitle: Text(Fmt.money(data.totalCommission)),
                ),
              ),
            ]),
            const Divider(),
            Row(children: [
              Expanded(
                child: ListTile(
                  leading: Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.teal),
                  title: Text(AppLang.tr('netProfit')),
                  subtitle: Text(Fmt.money(data.netProfit)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Cash Collection report — the main collection log per machine.
class _CollectionReportCard extends StatelessWidget {
  const _CollectionReportCard({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    if (data.collectionsByMachine.isEmpty) return const SizedBox.shrink();
    var totalCollected = 0.0;
    var totalCount = 0;
    for (final r in data.collectionsByMachine) {
      totalCollected += (r['total_collected'] as num?)?.toDouble() ?? 0;
      totalCount += (r['collection_count'] as num?)?.toInt() ?? 0;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLang.tr('collectionReport'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ListTile(
                  leading:
                      const Icon(Icons.payments_outlined, color: Colors.indigo),
                  title: Text(AppLang.tr('totalCollected')),
                  subtitle: Text(Fmt.money(totalCollected)),
                ),
              ),
              Expanded(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined,
                      color: Colors.indigo),
                  title: Text(AppLang.tr('collectionCount')),
                  subtitle: Text('$totalCount'),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            DataTable(
              headingRowColor:
                  WidgetStatePropertyAll(AppColors.blue.withValues(alpha: .06)),
              columns: [
                DataColumn(label: Text(AppLang.tr('machine'))),
                DataColumn(
                    label: Text(AppLang.tr('collectionCount')), numeric: true),
                DataColumn(
                    label: Text(AppLang.tr('totalCollected')), numeric: true),
              ],
              rows: data.collectionsByMachine.map((r) {
                return DataRow(cells: [
                  DataCell(Text('${r['machine_name']}')),
                  DataCell(
                      Text('${(r['collection_count'] as num?)?.toInt() ?? 0}')),
                  DataCell(Text(
                      Fmt.money((r['total_collected'] as num?)?.toDouble() ?? 0))),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Spending report section — inventory + utilities totals for the period.
class _SpendingCard extends StatelessWidget {
  const _SpendingCard({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    if (data.totalSpending == 0) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLang.tr('spending'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory_2_outlined,
                  color: Colors.green),
              title: Text(AppLang.tr('inventorySpending')),
              trailing: Text(Fmt.money(data.inventorySpending),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.electrical_services,
                  color: Colors.orange),
              title: Text(AppLang.tr('utilitiesSpending')),
              trailing: Text(Fmt.money(data.utilitiesSpending),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.shopping_bag_outlined,
                  color: Colors.red),
              title: Text(AppLang.tr('totalSpending'),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              trailing: Text(Fmt.money(data.totalSpending),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }
}
