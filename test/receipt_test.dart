import 'package:flutter_test/flutter_test.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/features/receipts/sales_receipt_service.dart';

void main() {
  group('SalesReceipt settlement calculations', () {
    SalesReceipt build({
      required List<double> collections,
      required List<double> changes,
      double commissionPercent = 10,
      String code = 'M1',
    }) {
      final tx = <ReceiptTransaction>[
        for (final c in collections)
          ReceiptTransaction(
              date: DateTime(2026, 8, 1), type: 'collection', amount: c),
        for (final c in changes)
          ReceiptTransaction(
              date: DateTime(2026, 8, 2), type: 'change', amount: c),
      ];
      final totalCollected = collections.fold<double>(0, (s, v) => s + v);
      final totalChange = changes.fold<double>(0, (s, v) => s + v);
      return SalesReceipt(
        machine: Machine(id: 1, name: 'M', code: code, location: 'L'),
        month: DateTime(2026, 8, 1),
        transactions: tx,
        totalCollected: totalCollected,
        totalAddedChange: totalChange,
        commissionPercent: commissionPercent,
      );
    }

    test('Net amount = collected - change', () {
      final r = build(collections: [250, 350, 200], changes: [50, 25]);
      expect(r.totalCollected, 800.0);
      expect(r.totalAddedChange, 75.0);
      expect(r.netAmount, 725.0);
    });

    test('Commission = net × percentage / 100', () {
      final r = build(
          collections: [250, 350, 200],
          changes: [50, 25],
          commissionPercent: 10);
      expect(r.commissionAmount, 72.50);
    });

    test('Commission uses NET amount, not collected', () {
      // If commission used collected (800) it would be 80, not 72.5.
      final r = build(
          collections: [250, 350, 200],
          changes: [50, 25],
          commissionPercent: 10);
      expect(r.commissionAmount, 72.50);
      expect(r.commissionAmount, isNot(80.0));
    });

    test('Transactions keep collection/change signs', () {
      final r = build(collections: [250], changes: [50]);
      final collection = r.transactions.first;
      final change = r.transactions[1];
      expect(collection.isCollection, isTrue);
      expect(change.isCollection, isFalse);
      expect(change.type, 'change');
    });
  });
}
