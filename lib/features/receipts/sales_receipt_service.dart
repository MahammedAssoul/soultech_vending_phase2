import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/repositories/cash_collection_repository.dart';
import 'package:soultech_vending/data/repositories/change_added_repository.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';

/// A single line in the receipt transaction list.
class ReceiptTransaction {
  const ReceiptTransaction({
    required this.date,
    required this.type,
    required this.amount,
    this.notes = '',
  });

  final DateTime date;

  /// 'collection' or 'change'.
  final String type;
  final double amount;
  final String notes;

  bool get isCollection => type == 'collection';
}

/// Aggregated monthly cash settlement receipt for a machine.
///
/// This is a CASH COLLECTION / SETTLEMENT receipt — NOT a sales/profit report.
/// Net amount = total collected cash − total added change.
class SalesReceipt {
  SalesReceipt({
    required this.machine,
    required this.month,
    required this.transactions,
    required this.totalCollected,
    required this.totalAddedChange,
    required this.commissionPercent,
  });

  final Machine machine;

  /// Selected month (first day of month).
  final DateTime month;

  /// All cash movements (collections + change added) ordered by date.
  final List<ReceiptTransaction> transactions;

  final double totalCollected;
  final double totalAddedChange;
  final double commissionPercent;

  /// Net amount = total collected cash − total added change.
  double get netAmount => totalCollected - totalAddedChange;

  /// Commission amount = net amount × (commission % / 100).
  double get commissionAmount => netAmount * (commissionPercent / 100);
}

/// Builds monthly cash settlement receipts from the real database.
class SalesReceiptService {
  final _collectionRepo = CashCollectionRepository();
  final _changeRepo = ChangeAddedRepository();
  final _machineRepo = MachineRepository();

  /// Builds the receipt for [machine] in [month] (year + month).
  Future<SalesReceipt> build({
    required int machineId,
    required DateTime month,
  }) async {
    final machine = await _machineRepo.getById(machineId);
    final m = machine ??
        Machine(
          id: machineId,
          name: 'Machine $machineId',
          code: '',
          location: '',
        );
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0);

    final collections =
        await _collectionRepo.getAll(machineId: machineId, from: from, to: to);
    final changes =
        await _changeRepo.getAll(machineId: machineId, from: from, to: to);

    final totalCollected =
        collections.fold<double>(0, (sum, c) => sum + c.collectedAmount);
    final totalAddedChange =
        changes.fold<double>(0, (sum, c) => sum + c.amount);

    // Build the transaction list (collections + change), ordered by date.
    final transactions = <ReceiptTransaction>[
      for (final c in collections)
        ReceiptTransaction(
          date: c.date,
          type: 'collection',
          amount: c.collectedAmount,
          notes: c.notes,
        ),
      for (final c in changes)
        ReceiptTransaction(
          date: c.date,
          type: 'change',
          amount: c.amount,
          notes: c.notes,
        ),
    ]..sort((a, b) => a.date.compareTo(b.date));

    return SalesReceipt(
      machine: m,
      month: from,
      transactions: transactions,
      totalCollected: totalCollected,
      totalAddedChange: totalAddedChange,
      commissionPercent: m.commissionPercent,
    );
  }

  /// Short monthly summary per machine for the machine-list screen.
  Future<List<Map<String, Object?>>> machineSummaries(DateTime month) async {
    final machines = await _machineRepo.getAll();
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0);

    final result = <Map<String, Object?>>[];
    for (final m in machines) {
      final id = m.id;
      if (id == null) continue;
      final collected =
          await _collectionRepo.getTotal(machineId: id, from: from, to: to);
      final change =
          await _changeRepo.getTotalByMachine(id, from: from, to: to);
      result.add({
        'machine': m,
        'totalCollected': collected,
        'totalAddedChange': change,
        'netAmount': collected - change,
      });
    }
    return result;
  }
}
