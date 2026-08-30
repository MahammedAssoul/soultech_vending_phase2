part of '../machine_details_page.dart';

/// Data helpers for the machine details page.
extension _LoadMachineData on _MachineDetailsPageState {
  DateTime _dateOf(Object r) => switch (r) {
        SaleRecord s => s.date,
        RestockingRecord s => s.date,
        ChangeAddedRecord s => s.date,
        CashReadingRecord s => s.date,
        CashCollectionRecord s => s.date,
        ReconciliationRecord s => s.date,
        _ => DateTime(2000),
      };

  List<Object> get _filteredRecords {
    if (_typeFilter == 'all') return _records;
    return _records.where((r) => _typeOf(r) == _typeFilter).toList();
  }

  String _typeOf(Object r) => switch (r) {
        SaleRecord _ => 'sale',
        RestockingRecord _ => 'restocking',
        ChangeAddedRecord _ => 'changeAdded',
        CashReadingRecord _ => 'cashReading',
        CashCollectionRecord _ => 'cashCollection',
        ReconciliationRecord _ => 'reconciliation',
        _ => '',
      };
}
