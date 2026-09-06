import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/theme/app_theme.dart';
import 'package:soultech_vending/core/theme/theme_controller.dart';
import 'package:soultech_vending/core/utils/format.dart';
import 'package:soultech_vending/core/widgets/app_drawer.dart';
import 'package:soultech_vending/core/widgets/soultech_logo.dart';
import 'package:soultech_vending/data/repositories/cash_collection_repository.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';
import 'package:soultech_vending/data/repositories/product_repository.dart';
import 'package:soultech_vending/data/repositories/sale_repository.dart';
import 'package:soultech_vending/data/repositories/spending_repository.dart';
import 'package:soultech_vending/features/dashboard/commission_details_page.dart';
import 'package:soultech_vending/features/dashboard/profit_details_page.dart';
import 'package:soultech_vending/features/machines/machines_page.dart';
import 'package:soultech_vending/features/receipts/sales_receipt_page.dart';
import 'package:soultech_vending/features/records/cash_collection_form_page.dart';
import 'package:soultech_vending/features/records/records_page.dart';
import 'package:soultech_vending/features/reports/reports_page.dart';
import 'package:soultech_vending/features/settings/settings_page.dart';
import 'package:soultech_vending/features/spending/spending_records_page.dart';

part 'components/stat_card.dart';
part 'components/sales_chart.dart';
part 'components/collection_chart.dart';
part 'components/quick_action_widget.dart';
part 'components/spending_stat_card.dart';
part 'components/top_machines.dart';
part 'components/low_stock_widget.dart';
part 'extensions/load_data.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  String? _error;

  // Summary values
  int _totalMachines = 0;
  int _activeMachines = 0;
  double _totalSales = 0;
  double _monthProfit = 0;
  double _monthCommission = 0;
  double _lowStockCount = 0;
  double _monthCollected = 0;
  double _monthTotalSpending = 0;
  double _monthInventorySpending = 0;
  double _monthUtilitiesSpending = 0;

  // Charts
  List<FlSpot> _salesSpots = [];
  List<FlSpot> _collectionSpots = [];
  int _range = 7; // days: 7 or 30

  // Top machines
  List<Map<String, Object?>> _topMachines = [];

  /// Current month name, e.g. 'June'.
  String get _monthName => DateFormat('MMMM')
      .format(DateTime(DateTime.now().year, DateTime.now().month));

  final _saleRepo = SaleRepository();
  final _collectionRepo = CashCollectionRepository();
  final _spendingRepo = SpendingRepository();
  final _machineRepo = MachineRepository();
  final _productRepo = ProductRepository();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      final machines = await _machineRepo.getAll();
      final active = machines.where((m) => m.active).length;

      final allTime = await _saleRepo.getSummary();
      final thisMonth = await _saleRepo.getSummary(from: monthStart, to: now);

      final commission = await _saleRepo.getTotalCommissionByMachine(
          from: monthStart, to: now);
      final lowStock = await _productRepo.getLowStock();

      final byDay = await _saleRepo.getSalesByDay(
          from: now.subtract(Duration(days: _range)), to: now);
      final spots = <FlSpot>[];
      for (var i = 0; i < byDay.length; i++) {
        final d = DateTime.parse(byDay[i]['date'] as String);
        spots.add(FlSpot(
            d
                .difference(now.subtract(Duration(days: _range)))
                .inDays
                .toDouble(),
            (byDay[i]['daily_sales'] as num?)?.toDouble() ?? 0));
      }

      // Cash collections (total this month + daily chart data)
      final monthCollected =
          await _collectionRepo.getTotal(from: monthStart, to: now);
      final collByDay = await _collectionRepo.getCollectionsByDay(
          from: now.subtract(Duration(days: _range)), to: now);
      final collSpots = <FlSpot>[];
      for (var i = 0; i < collByDay.length; i++) {
        final d = DateTime.parse(collByDay[i]['date'] as String);
        collSpots.add(FlSpot(
            d
                .difference(now.subtract(Duration(days: _range)))
                .inDays
                .toDouble(),
            (collByDay[i]['daily_collected'] as num?)?.toDouble() ?? 0));
      }

      final byMachine =
          await _saleRepo.getSalesByMachine(from: monthStart, to: now);
      final top = byMachine.take(5).toList();

      // Current-month spending total (database aggregation)
      final spending = await _spendingRepo.getCurrentMonthTotals();

      if (!mounted) return;
      setState(() {
        _totalMachines = machines.length;
        _activeMachines = active;
        _totalSales = allTime['total_sales'] ?? 0;
        _monthProfit = thisMonth['total_profit'] ?? 0;
        _monthCommission = commission;
        _lowStockCount = lowStock.length.toDouble();
        _monthCollected = monthCollected;
        _monthInventorySpending = spending['inventory_total'] ?? 0;
        _monthUtilitiesSpending = spending['utilities_total'] ?? 0;
        _monthTotalSpending = spending['total'] ?? 0;
        _salesSpots = spots;
        _collectionSpots = collSpots;
        _topMachines = top;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(current: DrawerSection.home),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
            tooltip: AppLang.tr(L.appMenu),
          ),
        ),
        title: const SoultechLogo(width: 145),
        actions: [
          ListenableBuilder(
            listenable: ThemeController.instance,
            builder: (context, _) => IconButton(
              onPressed: () => ThemeController.instance.toggle(),
              icon: Icon(ThemeController.instance.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined),
              tooltip: AppLang.tr('theme'),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsPage())),
            icon: const Icon(Icons.settings_outlined),
            tooltip: AppLang.tr('settings'),
          ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: AppLang.tr('refresh'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('${AppLang.tr('error')}: $_error'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    return RefreshIndicator(
                      onRefresh: _load,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLang.tr('overview'),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Soultech Vending • Phase 2 management dashboard',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 20),
                            // Summary grid
                            GridView.count(
                              crossAxisCount: wide ? 4 : 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 10,
                              childAspectRatio: wide ? 1.9 : 1.3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                // _StatCard(
                                //   title: AppLang.tr('totalSales'),
                                //   value: Fmt.money(_totalSales),
                                //   icon: Icons.point_of_sale,
                                //   color: AppColors.blue,
                                // ),
                                _StatCard(
                                  title:
                                      '$_monthName ${AppLang.tr('collected')}',
                                  value: Fmt.money(_monthCollected),
                                  icon: Icons.payments_outlined,
                                  color: Colors.indigo,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const SalesReceiptPage())),
                                ),
                                _StatCard(
                                  title: AppLang.tr('totalMachines'),
                                  subTitle:
                                      '$_activeMachines ${AppLang.tr('active')}',
                                  value: '$_totalMachines',
                                  icon: Icons.local_shipping_outlined,
                                  color: AppColors.navy,
                                  alignment: Alignment.centerRight,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const MachinesPage())),
                                ),
                                _StatCard(
                                  title:
                                      '$_monthName ${AppLang.tr('commission')}',
                                  value: Fmt.money(_monthCommission),
                                  icon: Icons.percent,
                                  color: AppColors.lightBlue,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const CommissionDetailsPage())),
                                ),

                                _StatCard(
                                  title:
                                      '$_monthName ${AppLang.tr('spending')}',
                                  value: Fmt.money(_monthTotalSpending),
                                  icon: Icons.payments_outlined,
                                  color: Colors.red,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const SpendingRecordsPage())),
                                ),
                                _StatCard(
                                  title: '$_monthName ${AppLang.tr('profit')}',
                                  value: Fmt.money(_monthCollected -
                                      _monthTotalSpending -
                                      _monthCommission),
                                  icon: Icons.trending_up,
                                  color: Colors.green,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ProfitDetailsPage())),
                                ),
                              ],
                            ),
                            // Chart + quick actions
                            if (wide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _SalesChart(
                                      spots: _salesSpots,
                                      range: _range,
                                      onRangeChanged: (v) {
                                        setState(() => _range = v);
                                        _load();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _QuickActions(
                                      onCollectCash: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const CashCollectionFormPage())),
                                      onSpending: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const SpendingRecordsPage())),
                                      onReceipt: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const SalesReceiptPage())),
                                      onRecords: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const RecordsPage())),
                                      onMachines: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const MachinesPage())),
                                      onReports: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const ReportsPage())),
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _SalesChart(
                                spots: _salesSpots,
                                range: _range,
                                onRangeChanged: (v) {
                                  setState(() => _range = v);
                                  _load();
                                },
                              ),
                              const SizedBox(height: 16),
                              _QuickActions(
                                onCollectCash: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const CashCollectionFormPage())),
                                onSpending: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const SpendingRecordsPage())),
                                onReceipt: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const SalesReceiptPage())),
                                onRecords: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const RecordsPage())),
                                onMachines: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const MachinesPage())),
                                onReports: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ReportsPage())),
                              ),
                            ],
                            const SizedBox(height: 20),
                            _CollectionChart(spots: _collectionSpots),
                            const SizedBox(height: 20),
                            _TopMachinesWidget(topMachines: _topMachines),
                            const SizedBox(height: 20),
                            LowStockWidget(lowStockCount: _lowStockCount),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
