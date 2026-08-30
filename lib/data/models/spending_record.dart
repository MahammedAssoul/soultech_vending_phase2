/// Spending categories.
enum SpendingType {
  inventory,
  utilities;

  String get dbValue => switch (this) {
        SpendingType.inventory => 'inventory',
        SpendingType.utilities => 'utilities',
      };

  static SpendingType fromDb(String? v) =>
      v == 'utilities' ? SpendingType.utilities : SpendingType.inventory;
}

/// A business spending record (inventory or utilities).
///
/// `machineId` is optional — a spending may apply to the whole business.
class SpendingRecord {
  final int? id;
  final SpendingType type;
  final DateTime date;
  final double amount;
  final String description;
  final int? machineId;

  /// Inventory only.
  final String supplier;

  /// Utilities only.
  final String utilityType;

  final String referenceNumber;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SpendingRecord({
    this.id,
    required this.type,
    required this.date,
    required this.amount,
    this.description = '',
    this.machineId,
    this.supplier = '',
    this.utilityType = '',
    this.referenceNumber = '',
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });

  factory SpendingRecord.now({
    int? id,
    required SpendingType type,
    required DateTime date,
    required double amount,
    String description = '',
    int? machineId,
    String supplier = '',
    String utilityType = '',
    String referenceNumber = '',
    String notes = '',
  }) =>
      SpendingRecord(
        id: id,
        type: type,
        date: date,
        amount: amount,
        description: description,
        machineId: machineId,
        supplier: supplier,
        utilityType: utilityType,
        referenceNumber: referenceNumber,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  SpendingRecord copyWith({
    int? id,
    SpendingType? type,
    DateTime? date,
    double? amount,
    String? description,
    int? machineId,
    String? supplier,
    String? utilityType,
    String? referenceNumber,
    String? notes,
    DateTime? updatedAt,
  }) =>
      SpendingRecord(
        id: id ?? this.id,
        type: type ?? this.type,
        date: date ?? this.date,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        machineId: machineId ?? this.machineId,
        supplier: supplier ?? this.supplier,
        utilityType: utilityType ?? this.utilityType,
        referenceNumber: referenceNumber ?? this.referenceNumber,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'type': type.dbValue,
        'date': date.toIso8601String().split('T').first,
        'amount': amount,
        'description': description,
        'machine_id': machineId,
        'supplier': supplier,
        'utility_type': utilityType,
        'reference_number': referenceNumber,
        'notes': notes,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory SpendingRecord.fromMap(Map<String, Object?> map) => SpendingRecord(
        id: map['id'] as int?,
        type: SpendingType.fromDb(map['type'] as String?),
        date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        description: map['description'] as String? ?? '',
        machineId: map['machine_id'] as int?,
        supplier: map['supplier'] as String? ?? '',
        utilityType: map['utility_type'] as String? ?? '',
        referenceNumber: map['reference_number'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? ''),
        updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? ''),
      );
}
