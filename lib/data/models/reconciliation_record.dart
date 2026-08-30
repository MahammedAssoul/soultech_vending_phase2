class ReconciliationRecord {
  final int? id;
  final int machineId;
  final double expectedAmount;
  final double actualAmount;
  final double difference;
  final DateTime date;
  final String notes;

  const ReconciliationRecord({
    this.id,
    required this.machineId,
    required this.expectedAmount,
    required this.actualAmount,
    required this.date,
    this.notes = '',
  }) : difference = actualAmount - expectedAmount;

  bool get isBalanced => difference == 0;
  bool get hasSurplus => difference > 0;
  bool get hasShortage => difference < 0;

  Map<String, Object?> toMap() => {
        'id': id,
        'machine_id': machineId,
        'expected_amount': expectedAmount,
        'actual_amount': actualAmount,
        'difference': difference,
        'date': date.toIso8601String().split('T').first,
        'notes': notes,
      };

  factory ReconciliationRecord.fromMap(Map<String, Object?> map) =>
      ReconciliationRecord(
        id: map['id'] as int?,
        machineId: map['machine_id'] as int? ?? 0,
        expectedAmount: (map['expected_amount'] as num?)?.toDouble() ?? 0,
        actualAmount: (map['actual_amount'] as num?)?.toDouble() ?? 0,
        date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
        notes: map['notes'] as String? ?? '',
      );
}
