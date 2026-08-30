class CashCollectionRecord {
  final int? id;
  final int machineId;

  /// Amount of cash collected from the machine.
  final double collectedAmount;
  final DateTime date;
  final String time;
  final String notes;

  const CashCollectionRecord({
    this.id,
    required this.machineId,
    this.collectedAmount = 0,
    required this.date,
    this.time = '',
    this.notes = '',
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'machine_id': machineId,
        'collected_amount': collectedAmount,
        'date': date.toIso8601String().split('T').first,
        'time': time,
        'notes': notes,
      };

  factory CashCollectionRecord.fromMap(Map<String, Object?> map) =>
      CashCollectionRecord(
        id: map['id'] as int?,
        machineId: map['machine_id'] as int? ?? 0,
        collectedAmount: (map['collected_amount'] as num?)?.toDouble() ?? 0,
        date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
        time: map['time'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
      );
}
