class Product {
  final int? id;
  final String name;
  final String category;
  final double sellingPrice;
  final double costPrice;
  final int lowStockThreshold;
  final int currentStock;
  final int minStock;
  final bool active;
  final String notes;

  const Product({
    this.id,
    required this.name,
    this.category = '',
    required this.sellingPrice,
    required this.costPrice,
    this.lowStockThreshold = 5,
    this.currentStock = 0,
    this.minStock = 5,
    this.active = true,
    this.notes = '',
  });

  bool get isOutOfStock => currentStock <= 0;
  bool get isLowStock => currentStock > 0 && currentStock <= minStock;
  bool get isInStock => currentStock > minStock;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'selling_price': sellingPrice,
        'cost_price': costPrice,
        'low_stock_threshold': lowStockThreshold,
        'current_stock': currentStock,
        'min_stock': minStock,
        'active': active ? 1 : 0,
        'notes': notes,
      };

  factory Product.fromMap(Map<String, Object?> map) => Product(
        id: map['id'] as int?,
        name: map['name'] as String? ?? '',
        category: map['category'] as String? ?? '',
        sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0,
        costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0,
        lowStockThreshold: map['low_stock_threshold'] as int? ?? 5,
        currentStock: map['current_stock'] as int? ?? 0,
        minStock: map['min_stock'] as int? ?? 5,
        active: (map['active'] as int? ?? 1) == 1,
        notes: map['notes'] as String? ?? '',
      );

  Product copyWith({
    int? id,
    String? name,
    String? category,
    double? sellingPrice,
    double? costPrice,
    int? lowStockThreshold,
    int? currentStock,
    int? minStock,
    bool? active,
    String? notes,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        sellingPrice: sellingPrice ?? this.sellingPrice,
        costPrice: costPrice ?? this.costPrice,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        currentStock: currentStock ?? this.currentStock,
        minStock: minStock ?? this.minStock,
        active: active ?? this.active,
        notes: notes ?? this.notes,
      );
}
