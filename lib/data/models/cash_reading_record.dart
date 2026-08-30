class CashReadingRecord {
  final int? id;
  final int machineId;
  final double readingAmount;
  final DateTime date;
  final String time;
  final String notes;

  const CashReadingRecord({
    this.id,
    required this.machineId,
    required this.readingAmount,
    required this.date,
    this.time = '',
    this.notes = '',
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'machine_id': machineId,
        'reading_amount': readingAmount,
        'date': date.toIso8601String().split('T').first,
        'time': time,
        'notes': notes,
      };

  factory CashReadingRecord.fromMap(Map<String, Object?> map) =>
      CashReadingRecord(
        id: map['id'] as int?,
        machineId: map['machine_id'] as int? ?? 0,
        readingAmount: (map['reading_amount'] as num?)?.toDouble() ?? 0,
        date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
        time: map['time'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
      );
}
