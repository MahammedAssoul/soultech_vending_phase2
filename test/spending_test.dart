import 'package:flutter_test/flutter_test.dart';
import 'package:soultech_vending/data/models/spending_record.dart';

void main() {
  group('Spending type separation', () {
    test('db values are distinct', () {
      expect(SpendingType.inventory.dbValue, 'inventory');
      expect(SpendingType.utilities.dbValue, 'utilities');
      expect(SpendingType.fromDb('inventory'), SpendingType.inventory);
      expect(SpendingType.fromDb('utilities'), SpendingType.utilities);
    });
  });

  group('Spending totals aggregation (pure logic)', () {
    // Mirrors the SQL SUM(CASE WHEN type ...) in SpendingRepository
    double inventoryTotal(List<SpendingRecord> records) => records
        .where((r) => r.type == SpendingType.inventory)
        .fold(0, (s, r) => s + r.amount);

    double utilitiesTotal(List<SpendingRecord> records) => records
        .where((r) => r.type == SpendingType.utilities)
        .fold(0, (s, r) => s + r.amount);

    double total(List<SpendingRecord> records) =>
        records.fold(0, (s, r) => s + r.amount);

    @pragma('vm:prefer-inline')
    SpendingRecord record(SpendingType type, double amount, {DateTime? date}) =>
        SpendingRecord(
          type: type,
          date: date ?? DateTime(2026, 8, 1),
          amount: amount,
        );

    test('TEST 1: inventory 100/200/300 + utilities 50/75 → 600/125/725', () {
      final records = <SpendingRecord>[
        record(SpendingType.inventory, 100),
        record(SpendingType.inventory, 200),
        record(SpendingType.inventory, 300),
        record(SpendingType.utilities, 50),
        record(SpendingType.utilities, 75),
      ];
      expect(inventoryTotal(records), 600);
      expect(utilitiesTotal(records), 125);
      expect(total(records), 725);
    });

    test('TEST 2: August vs September month isolation', () {
      final records = <SpendingRecord>[
        record(SpendingType.inventory, 500, date: DateTime(2026, 8, 10)),
        record(SpendingType.utilities, 200, date: DateTime(2026, 8, 20)),
        record(SpendingType.inventory, 900, date: DateTime(2026, 9, 1)),
        record(SpendingType.utilities, 300, date: DateTime(2026, 9, 5)),
      ];
      // Filter "current month = August 2026" using [first of month, first of next)
      final from = DateTime(2026, 8, 1);
      final to = DateTime(2026, 9, 1);
      final aug = records
          .where((r) => !r.date.isBefore(from) && r.date.isBefore(to))
          .toList();
      expect(total(aug), 700);
      expect(inventoryTotal(aug), 500);
      expect(utilitiesTotal(aug), 200);

      final sep = records
          .where((r) =>
              !r.date.isBefore(DateTime(2026, 9, 1)) &&
              r.date.isBefore(DateTime(2026, 10, 1)))
          .toList();
      expect(total(sep), 1200);
    });

    test('TEST 6: inventory records excluded from utilities type filter', () {
      final records = <SpendingRecord>[
        record(SpendingType.inventory, 100),
        record(SpendingType.inventory, 200),
        record(SpendingType.utilities, 50),
      ];
      final utilities =
          records.where((r) => r.type == SpendingType.utilities).toList();
      expect(utilities.length, 1);
      expect(utilities.every((r) => r.type == SpendingType.utilities), isTrue);
      expect(utilities.fold<double>(0, (s, r) => s + r.amount), 50);
    });

    test('TEST 7: utilities records excluded from inventory type filter', () {
      final records = <SpendingRecord>[
        record(SpendingType.inventory, 100),
        record(SpendingType.utilities, 50),
        record(SpendingType.utilities, 25),
      ];
      final inventory =
          records.where((r) => r.type == SpendingType.inventory).toList();
      expect(inventory.length, 1);
      expect(inventory.every((r) => r.type == SpendingType.inventory), isTrue);
      expect(inventory.fold<double>(0, (s, r) => s + r.amount), 100);
    });

    test('SpendingRecord.now sets timestamps', () {
      final r = SpendingRecord.now(
        type: SpendingType.inventory,
        date: DateTime(2026, 8, 1),
        amount: 10,
      );
      expect(r.createdAt, isNotNull);
      expect(r.updatedAt, isNotNull);
    });

    test('copyWith updates amount and timestamp', () {
      final r = SpendingRecord.now(
        type: SpendingType.inventory,
        date: DateTime(2026, 8, 1),
        amount: 10,
      );
      final updated = r.copyWith(amount: 25, updatedAt: DateTime(2026, 8, 2));
      expect(updated.amount, 25);
      expect(updated.updatedAt, DateTime(2026, 8, 2));
      expect(updated.id, r.id);
    });
  });
}
