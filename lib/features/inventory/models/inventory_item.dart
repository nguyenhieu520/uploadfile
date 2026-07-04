class InventoryItem {
  final String id;
  final String code;
  final String name;
  final String unit;
  final double stock;
  final double minStock;
  final double importPrice;

  InventoryItem({
    required this.id,
    required this.code,
    required this.name,
    required this.unit,
    required this.stock,
    required this.minStock,
    required this.importPrice,
  });
}