import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../models/inventory.dart';

class InventoryDao {
  static Future<List<InventoryItem>> getAll() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query('products', where: 'is_raw_material = 1 OR category_id IN ("CAT004")');
    return result.map((e) => InventoryItem.fromMap(e)).toList();
  }

  static Future<void> importProduct(String productId, double quantity, double price) async {
    final db = await AppDatabase.instance.database;
    // Thêm vào đầu hàm createOrder
    await FirebaseSyncService.instance.queue('orders', order.toMap());
    // Sau khi lưu xong các item
    for (final item in items) {
        await FirebaseSyncService.instance.queue('order_items', item.toMap());
    }
    await db.transaction((txn) async {
      // Cập nhật tồn kho
      await txn.rawUpdate('''
        UPDATE products SET current_stock = current_stock + ? WHERE id = ?
      ''', [quantity, productId]);

      // Ghi giao dịch nhập kho
      await txn.insert('inventory_transactions', {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'code': 'IMP${DateTime.now().millisecondsSinceEpoch}',
        'type': 'import',
        'product_id': productId,
        'quantity': quantity,
        'unit_price': price,
        'total_price': quantity * price,
        'staff_id': 'ADMIN001',
      });
    });
  }
}