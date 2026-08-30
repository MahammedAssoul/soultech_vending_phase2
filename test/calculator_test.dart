import 'package:flutter_test/flutter_test.dart';
import 'package:soultech_vending/core/services/calculator.dart';
import 'package:soultech_vending/data/models/reconciliation_record.dart';
import 'package:soultech_vending/data/models/sale_record.dart';

void main() {
  group('Sale calculations', () {
    test('quantity=10, unit=5, cost=3 → Sales=50, Cost=30, Profit=20', () {
      final qty = 10.0;
      final unit = 5.0;
      final cost = 3.0;

      expect(Calc.saleTotal(qty, unit), 50.0);
      expect(Calc.saleCost(qty, cost), 30.0);
      expect(Calc.saleProfit(qty, unit, cost), 20.0);
    });

    test('SaleRecord.calculated computes totals', () {
      final sale = SaleRecord.calculated(
        machineId: 1,
        quantity: 10,
        unitPrice: 5,
        costPrice: 3,
        date: DateTime(2026, 8, 1),
      );
      expect(sale.totalAmount, 50.0);
      expect(sale.totalCost, 30.0);
      expect(sale.profit, 20.0);
    });
  });

  group('Commission', () {
    test('Sales=1000, Commission=10% → Commission=100', () {
      expect(Calc.commission(1000, 10), 100.0);
    });

    test('Commission at 0% is zero', () {
      expect(Calc.commission(1000, 0), 0.0);
    });
  });

  group('Gross profit', () {
    test('Sales=1000, Cost=600 → Gross Profit=400', () {
      expect(Calc.grossProfit(1000, 600), 400.0);
    });
  });

  group('Net profit', () {
    test('Gross Profit=400, Commission=100 → Net Profit=300', () {
      expect(Calc.netProfit(400, 100), 300.0);
    });
  });

  group('Reconciliation', () {
    test('Expected=500, Actual=475 → Difference=-25', () {
      expect(Calc.reconciliationDifference(500, 475), -25.0);
    });

    test('ReconciliationRecord computes difference', () {
      final r = ReconciliationRecord(
        machineId: 1,
        expectedAmount: 500,
        actualAmount: 475,
        date: DateTime(2026, 8, 1),
      );
      expect(r.difference, -25.0);
      expect(r.hasShortage, isTrue);
      expect(r.isBalanced, isFalse);
    });

    test('Balanced when expected == actual', () {
      final r = ReconciliationRecord(
        machineId: 1,
        expectedAmount: 500,
        actualAmount: 500,
        date: DateTime(2026, 8, 1),
      );
      expect(r.difference, 0.0);
      expect(r.isBalanced, isTrue);
    });
  });

  group('Average sale (division by zero safety)', () {
    test('Returns 0 when no transactions', () {
      expect(Calc.averageSale(0, 0), 0.0);
    });

    test('Computes average correctly', () {
      expect(Calc.averageSale(1000, 4), 250.0);
    });
  });

  group('Restocking cost', () {
    test('quantity=20, unitCost=2.5 → totalCost=50', () {
      expect(Calc.restockingCost(20, 2.5), 50.0);
    });
  });
}
