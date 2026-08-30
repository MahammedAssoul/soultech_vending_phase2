class Product {
  final int? id;
  final String name;
  final String category;
  final double sellingPrice;
  final double costPrice;
  final int lowStockThreshold;

  const Product({
    this.id,
    required this.name,
    required this.category,
    required this.sellingPrice,
    required this.costPrice,
    this.lowStockThreshold = 5,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'selling_price': sellingPrice,
        'cost_price': costPrice,
        'low_stock_threshold': lowStockThreshold,
      };
}
