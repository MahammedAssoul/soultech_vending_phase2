class ChangeAddedRecord {
  final int? id;
  final int machineId;
  final double amount;
  final DateTime date;
  final String time;
  final String notes;

  const ChangeAddedRecord({
    this.id,
    required this.machineId,
    required this.amount,
    required this.date,
    this.time = '',
    this.notes = '',
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'machine_id': machineId,
        'amount': amount,
        'date': date.toIso8601String().split('T').first,
        'time': time,
        'notes': notes,
      };

  factory ChangeAddedRecord.fromMap(Map<String, Object?> map) =>
      ChangeAddedRecord(
        id: map['id'] as int?,
        machineId: map['machine_id'] as int? ?? 0,
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
        time: map['time'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
      );
}
