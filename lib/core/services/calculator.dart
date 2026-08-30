import 'package:soultech_vending/data/models/sale_record.dart';
import 'package:soultech_vending/data/models/reconciliation_record.dart';
import 'package:soultech_vending/data/models/restocking_record.dart';

/// Central business-calculation logic.
///
/// Keeping these as pure functions makes them unit-testable and guarantees the
/// same numbers appear in the UI, the databases and the exported reports.
class Calc {
  const Calc._();

  // ── Sale calculations ─────────────────────────────────────────────────────
  static double saleTotal(double quantity, double unitPrice) =>
      quantity * unitPrice;

  static double saleCost(double quantity, double costPrice) =>
      quantity * costPrice;

  static double saleProfit(
          double quantity, double unitPrice, double costPrice) =>
      saleTotal(quantity, unitPrice) - saleCost(quantity, costPrice);

  static double restockingCost(double quantity, double unitCost) =>
      quantity * unitCost;

  /// difference = actual - expected (per spec).
  static double reconciliationDifference(double expected, double actual) =>
      actual - expected;

  // ── Report calculations ───────────────────────────────────────────────────
  /// Commission on [totalSales] at [commissionPercent]% (0–100).
  static double commission(double totalSales, double commissionPercent) =>
      totalSales * commissionPercent / 100.0;

  /// Gross profit = total sales − total cost.
  static double grossProfit(double totalSales, double totalCost) =>
      totalSales - totalCost;

  /// Net profit = gross profit − commission.
  static double netProfit(double grossProfit, double commission) =>
      grossProfit - commission;

  /// Average sale = total sales / transactions (safe division by zero).
  static double averageSale(double totalSales, int transactions) =>
      transactions == 0 ? 0 : totalSales / transactions;

  // ── Record builders (match the model factories but explicit) ──────────────
  static SaleRecord buildSale({
    int? id,
    required int machineId,
    int? productId,
    String productName = '',
    required double quantity,
    required double unitPrice,
    required double costPrice,
    required DateTime date,
    String time = '',
    String notes = '',
  }) =>
      SaleRecord.calculated(
        id: id,
        machineId: machineId,
        productId: productId,
        productName: productName,
        quantity: quantity,
        unitPrice: unitPrice,
        costPrice: costPrice,
        date: date,
        time: time,
        notes: notes,
      );

  static RestockingRecord buildRestocking({
    int? id,
    required int machineId,
    int? productId,
    String productName = '',
    required double quantity,
    required double unitCost,
    required DateTime date,
    String notes = '',
  }) =>
      RestockingRecord.calculated(
        id: id,
        machineId: machineId,
        productId: productId,
        productName: productName,
        quantity: quantity,
        unitCost: unitCost,
        date: date,
        notes: notes,
      );

  static ReconciliationRecord buildReconciliation({
    int? id,
    required int machineId,
    required double expectedAmount,
    required double actualAmount,
    required DateTime date,
    String notes = '',
  }) =>
      ReconciliationRecord(
        id: id,
        machineId: machineId,
        expectedAmount: expectedAmount,
        actualAmount: actualAmount,
        date: date,
        notes: notes,
      );
}
