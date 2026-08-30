class RestockingRecord {
  final int? id;
  final int machineId;
  final int? productId;
  final String productName;
  final double quantity;
  final double unitCost;
  final double totalCost;
  final DateTime date;
  final String notes;

  const RestockingRecord({
    this.id,
    required this.machineId,
    this.productId,
    this.productName = '',
    required this.quantity,
    required this.unitCost,
    double? totalCost,
    required this.date,
    this.notes = '',
  }) : totalCost = totalCost ?? quantity * unitCost;

  factory RestockingRecord.calculated({
    int? id,
    required int machineId,
    int? productId,
    String productName = '',
    required double quantity,
    required double unitCost,
    required DateTime date,
    String notes = '',
  }) =>
      RestockingRecord(
        id: id,
        machineId: machineId,
        productId: productId,
        productName: productName,
        quantity: quantity,
        unitCost: unitCost,
        totalCost: quantity * unitCost,
        date: date,
        notes: notes,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'machine_id': machineId,
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'unit_cost': unitCost,
        'total_cost': totalCost,
        'date': date.toIso8601String().split('T').first,
        'notes': notes,
      };

  factory RestockingRecord.fromMap(Map<String, Object?> map) =>
      RestockingRecord(
        id: map['id'] as int?,
        machineId: map['machine_id'] as int? ?? 0,
        productId: map['product_id'] as int?,
        productName: map['product_name'] as String? ?? '',
        quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
        unitCost: (map['unit_cost'] as num?)?.toDouble() ?? 0,
        totalCost: (map['total_cost'] as num?)?.toDouble() ?? 0,
        date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
        notes: map['notes'] as String? ?? '',
      );
}
