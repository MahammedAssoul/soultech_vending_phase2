part of '../reports_page.dart';

class _MachinePerformanceCard extends StatelessWidget {
  const _MachinePerformanceCard({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final rows = data.salesByMachine;
    if (rows.isEmpty) return const SizedBox.shrink();
    final best = rows.first;
    final lowest = rows.last;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLang.tr('machinePerformance'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            DataTable(
              headingRowColor:
                  WidgetStatePropertyAll(AppColors.blue.withValues(alpha: .06)),
              columns: [
                DataColumn(label: Text(AppLang.tr('machine'))),
                DataColumn(
                    label: Text(AppLang.tr('totalSales')), numeric: true),
                DataColumn(
                    label: Text(AppLang.tr('transactions')), numeric: true),
                DataColumn(
                    label: Text(AppLang.tr('grossProfit')), numeric: true),
                DataColumn(
                    label: Text(AppLang.tr('commission')), numeric: true),
              ],
              rows: rows.map((r) {
                return DataRow(cells: [
                  DataCell(Text('${r['machine_name']}')),
                  DataCell(Text(
                      Fmt.money((r['total_sales'] as num?)?.toDouble() ?? 0))),
                  DataCell(
                      Text('${(r['transactions'] as num?)?.toInt() ?? 0}')),
                  DataCell(Text(
                      Fmt.money((r['gross_profit'] as num?)?.toDouble() ?? 0))),
                  DataCell(Text(
                      Fmt.money((r['commission'] as num?)?.toDouble() ?? 0))),
                ]);
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.emoji_events, color: Colors.amber),
                  title: Text(AppLang.tr('bestMachine')),
                  subtitle: Text('${best['machine_name']}'),
                ),
              ),
              Expanded(
                child: ListTile(
                  dense: true,
                  leading:
                      const Icon(Icons.arrow_downward, color: Colors.redAccent),
                  title: Text(AppLang.tr('lowestMachine')),
                  subtitle: Text('${lowest['machine_name']}'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ProductPerformanceCard extends StatelessWidget {
  const _ProductPerformanceCard({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final rows = data.salesByProduct;
    if (rows.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLang.tr('productPerformance'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            DataTable(
              headingRowColor:
                  WidgetStatePropertyAll(AppColors.blue.withValues(alpha: .06)),
              columns: [
                DataColumn(label: Text(AppLang.tr('product'))),
                DataColumn(
                    label: Text(AppLang.tr('quantitySold')), numeric: true),
                DataColumn(label: Text(AppLang.tr('revenue')), numeric: true),
                DataColumn(label: Text(AppLang.tr('profit')), numeric: true),
              ],
              rows: rows.map((r) {
                return DataRow(cells: [
                  DataCell(Text('${r['product_name']}')),
                  DataCell(Text(
                      Fmt.number((r['total_qty'] as num?)?.toDouble() ?? 0))),
                  DataCell(
                      Text(Fmt.money((r['revenue'] as num?)?.toDouble() ?? 0))),
                  DataCell(
                      Text(Fmt.money((r['profit'] as num?)?.toDouble() ?? 0))),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
