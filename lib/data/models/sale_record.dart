class SaleRecord {
  final int? id;
  final int machineId;
  final int? productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double totalAmount;
  final double costPrice;
  final double totalCost;
  final double profit;
  final DateTime date;
  final String time;
  final String notes;

  const SaleRecord({
    this.id,
    required this.machineId,
    this.productId,
    this.productName = '',
    this.quantity = 1,
    this.unitPrice = 0,
    this.totalAmount = 0,
    this.costPrice = 0,
    this.totalCost = 0,
    this.profit = 0,
    required this.date,
    this.time = '',
    this.notes = '',
  });

  /// Factory that calculates totals from inputs
  factory SaleRecord.calculated({
    int? id,
    required int machineId,
    int? productId,
    String productName = '',
    required double quantity,
    required double unitPrice,
    required double costPrice,
    required DateTime date,
    String time = '',
    String notes = '',
  }) {
    final totalAmount = quantity * unitPrice;
    final totalCost = quantity * costPrice;
    return SaleRecord(
      id: id,
      machineId: machineId,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      costPrice: costPrice,
      totalCost: totalCost,
      profit: totalAmount - totalCost,
      date: date,
      time: time,
      notes: notes,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'machine_id': machineId,
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_amount': totalAmount,
        'cost_price': costPrice,
        'total_cost': totalCost,
        'profit': profit,
        'date': date.toIso8601String().split('T').first,
        'time': time,
        'notes': notes,
      };

  factory SaleRecord.fromMap(Map<String, Object?> map) => SaleRecord(
        id: map['id'] as int?,
        machineId: map['machine_id'] as int? ?? 0,
        productId: map['product_id'] as int?,
        productName: map['product_name'] as String? ?? '',
        quantity: (map['quantity'] as num?)?.toDouble() ?? 1,
        unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0,
        totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0,
        costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0,
        totalCost: (map['total_cost'] as num?)?.toDouble() ?? 0,
        profit: (map['profit'] as num?)?.toDouble() ?? 0,
        date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
        time: map['time'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
      );
}
