part of '../reports_page.dart';

class _SalesTrendChart extends StatelessWidget {
  const _SalesTrendChart({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < data.salesByDay.length; i++) {
      final row = data.salesByDay[i];
      final sales = (row['daily_sales'] as num?)?.toDouble() ?? 0;
      spots.add(FlSpot(i.toDouble(), sales));
    }
    return ChartCard(
      title: AppLang.tr('salesTrend'),
      color: AppColors.blue,
      spots: spots,
    );
  }
}

class _ReportSummaryGrid extends StatelessWidget {
  const _ReportSummaryGrid({required this.data, required this.wide});
  final ReportData data;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: wide ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SummaryCard(
            title: AppLang.tr('totalSales'),
            value: Fmt.money(data.totalSales),
            icon: Icons.point_of_sale,
            color: AppColors.blue),
        SummaryCard(
            title: AppLang.tr('totalCost'),
            value: Fmt.money(data.totalCost),
            icon: Icons.shopping_cart_outlined,
            color: AppColors.navy),
        SummaryCard(
            title: AppLang.tr('grossProfit'),
            value: Fmt.money(data.grossProfit),
            icon: Icons.trending_up,
            color: Colors.green),
        SummaryCard(
            title: AppLang.tr('totalCommission'),
            value: Fmt.money(data.totalCommission),
            icon: Icons.percent,
            color: AppColors.lightBlue),
        SummaryCard(
            title: AppLang.tr('netProfit'),
            value: Fmt.money(data.netProfit),
            icon: Icons.account_balance_wallet_outlined,
            color: Colors.teal),
        SummaryCard(
            title: AppLang.tr('transactions'),
            value: '${data.transactions}',
            icon: Icons.receipt_long_outlined,
            color: Colors.orange),
        SummaryCard(
            title: AppLang.tr('avgSale'),
            value: Fmt.money(data.averageSale),
            icon: Icons.attach_money,
            color: Colors.indigo),
      ],
    );
  }
}
