import 'package:soultech_vending/core/services/calculator.dart';
import 'package:soultech_vending/data/models/spending_record.dart';
import 'package:soultech_vending/data/repositories/cash_collection_repository.dart';
import 'package:soultech_vending/data/repositories/cash_reading_repository.dart';
import 'package:soultech_vending/data/repositories/change_added_repository.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';
import 'package:soultech_vending/data/repositories/reconciliation_repository.dart';
import 'package:soultech_vending/data/repositories/restocking_repository.dart';
import 'package:soultech_vending/data/repositories/sale_repository.dart';
import 'package:soultech_vending/data/repositories/spending_repository.dart';

/// All aggregate data needed for the Reports page and the PDF/Excel exports.
class ReportData {
  ReportData({
    required this.machines,
    required this.salesByDay,
    required this.salesByMonth,
    required this.salesByMachine,
    required this.salesByProduct,
    required this.commissionByMachine,
    required this.restockingSummary,
    required this.restockingByMachine,
    required this.cashSummary,
    required this.collectionsByMachine,
    required this.spending,
    required this.spendings,
    required this.summary,
  });

  final List<Map<String, Object?>> machines;
  final List<Map<String, Object?>> salesByDay;
  final List<Map<String, Object?>> salesByMonth;
  final List<Map<String, Object?>> salesByMachine;
  final List<Map<String, Object?>> salesByProduct;
  final List<Map<String, Object?>> commissionByMachine;
  final Map<String, double> restockingSummary;
  final List<Map<String, Object?>> restockingByMachine;
  final List<Map<String, Object?>> cashSummary;
  final List<Map<String, Object?>> collectionsByMachine;
  final Map<String, double> spending;
  final List<SpendingRecord> spendings;
  final Map<String, double> summary;

  // Convenience typed getters
  double get totalSales => summary['total_sales'] ?? 0;
  double get totalCost => summary['total_cost'] ?? 0;
  double get grossProfit => summary['gross_profit'] ?? 0;
  double get totalCommission => summary['total_commission'] ?? 0;
  double get netProfit => summary['net_profit'] ?? 0;
  int get transactions => summary['transaction_count']?.toInt() ?? 0;
  double get averageSale => summary['avg_sale'] ?? 0;

  // Spending
  double get inventorySpending => spending['inventory_total'] ?? 0;
  double get utilitiesSpending => spending['utilities_total'] ?? 0;
  double get totalSpending => spending['total'] ?? 0;
}

/// Aggregates all report data within a date range / machine filter.
class ReportService {
  final _saleRepo = SaleRepository();
  final _restockRepo = RestockingRepository();
  final _machineRepo = MachineRepository();
  final _cashRepo = CashReadingRepository();
  final _changeRepo = ChangeAddedRepository();
  final _reconRepo = ReconciliationRepository();
  final _collectionRepo = CashCollectionRepository();
  final _spendingRepo = SpendingRepository();

  Future<ReportData> load({
    int? machineId,
    required DateTime from,
    required DateTime to,
  }) async {
    final machines = await _machineRepo.getAll();

    final salesByDay =
        await _saleRepo.getSalesByDay(machineId: machineId, from: from, to: to);
    final salesByMonth = await _saleRepo.getSalesByMonth(
        machineId: machineId, from: from, to: to);
    final salesByMachine = await _saleRepo
        .getSalesByMachine(from: from, to: to)
        .then((rows) => machineId == null
            ? rows
            : rows.where((r) => r['machine_id'] == machineId).toList());
    final salesByProduct = await _saleRepo.getSalesByProduct(
        machineId: machineId, from: from, to: to);
    final commissionByMachine = await _saleRepo
        .getCommissionByMachine(from: from, to: to)
        .then((rows) => machineId == null
            ? rows
            : rows.where((r) => r['machine_id'] == machineId).toList());

    final restockingSummary =
        await _restockRepo.getSummary(machineId: machineId, from: from, to: to);
    final restockingByMachine =
        await _getRestockingByMachine(machineId: machineId, from: from, to: to);
    final cashSummary = await _reconRepo
        .getCashSummaryByMachine(from: from, to: to)
        .then((rows) => machineId == null
            ? rows
            : rows.where((r) => r['machine_id'] == machineId).toList());
    final collectionsByMachine = await _collectionRepo
        .getCollectionsByMachine(from: from, to: to)
        .then((rows) => machineId == null
            ? rows
            : rows.where((r) => r['machine_id'] == machineId).toList());

    final saleSummary =
        await _saleRepo.getSummary(machineId: machineId, from: from, to: to);
    final totalSales = saleSummary['total_sales'] ?? 0;
    final totalCost = saleSummary['total_cost'] ?? 0;
    final transactions = (saleSummary['transaction_count'] ?? 0).toInt();

    final commission = await _saleRepo.getTotalCommission(
        machineId: machineId, from: from, to: to);
    final gross = Calc.grossProfit(totalSales, totalCost);
    final net = Calc.netProfit(gross, commission);

    // Spending totals for the selected report range.
    final spending = await _spendingRepo.getTotals(
      machineId: machineId,
      from: from,
      to: to,
    );
    final spendings = await _spendingRepo.getAll(
      machineId: machineId,
      from: from,
      to: to,
    );

    final summary = <String, double>{
      'total_sales': totalSales,
      'total_cost': totalCost,
      'gross_profit': gross,
      'total_commission': commission,
      'net_profit': net,
      'transaction_count': transactions.toDouble(),
      'avg_sale': Calc.averageSale(totalSales, transactions),
    };

    return ReportData(
      machines: machines.map((m) => m.toMap()).toList(),
      salesByDay: salesByDay,
      salesByMonth: salesByMonth,
      salesByMachine: salesByMachine,
      salesByProduct: salesByProduct,
      commissionByMachine: commissionByMachine,
      restockingSummary: restockingSummary,
      restockingByMachine: restockingByMachine,
      cashSummary: cashSummary,
      collectionsByMachine: collectionsByMachine,
      spending: spending,
      spendings: spendings,
      summary: summary,
    );
  }

  Future<List<Map<String, Object?>>> _getRestockingByMachine({
    int? machineId,
    required DateTime from,
    required DateTime to,
  }) async {
    return _restockRepo
        .getAll(machineId: machineId, from: from, to: to)
        .then((records) => records
            .map((r) => {
                  'date': r.date,
                  'product_name': r.productName,
                  'quantity': r.quantity,
                  'unit_cost': r.unitCost,
                  'total_cost': r.totalCost,
                })
            .toList());
  }

  /// Expected cash per machine =
  ///   SUM(cash readings) − SUM(change added) + reconciliation actuals adjustment.
  /// Projects simply report last cash reading + actual reconciliations.
  Future<List<Map<String, Object?>>> expectedCashByMachine() async {
    final machines = await _machineRepo.getAll();
    final result = <Map<String, Object?>>[];
    for (final m in machines) {
      final readings = await _cashRepo.getAll(machineId: m.id);
      final lastReading =
          readings.isEmpty ? 0.0 : _firstReadingAmount(readings.first);
      final changeAdded = await _changeRepo.getTotalByMachine(m.id!);
      result.add({
        'machine_id': m.id,
        'machine_name': m.name,
        'expected': lastReading,
        'change_added': changeAdded,
      });
    }
    return result;
  }

  double _firstReadingAmount(dynamic reading) {
    if (reading is Map<String, Object?>) {
      return (reading['reading_amount'] as num?)?.toDouble() ?? 0;
    }
    return 0;
  }
}
