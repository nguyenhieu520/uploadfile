import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../models/order.dart';

class OrderDao {
  static final AppDatabase _db = AppDatabase.instance;

  /// Tạo đơn hàng mới + tự động trừ kho theo công thức
  static Future<String> createOrder(Order order, List<OrderItem> items) async {
    final db = await _db.database;
    String orderId = '';

    // Thêm vào đầu hàm createOrder
    await FirebaseSyncService.instance.queue('orders', order.toMap());
    // Sau khi lưu xong các item
    for (final item in items) {
        await FirebaseSyncService.instance.queue('order_items', item.toMap());
    }

    // Trong OrderDao.createOrder
    await SyncService.instance.queueChange('orders', order.toMap());

    await db.transaction((txn) async {
      // 1. Lưu đơn hàng chính
      orderId = order.id;
      await txn.insert('orders', order.toMap());

      // 2. Lưu chi tiết đơn hàng
      for (var item in items) {
        await txn.insert('order_items', item.toMap());

        // 3. Tự động trừ tồn kho sản phẩm bán ra
        await txn.rawUpdate('''
          UPDATE products 
          SET current_stock = current_stock - ? 
          WHERE id = ?
        ''', [item.quantity, item.productId]);

        // 4. Trừ nguyên liệu theo công thức chế biến
        final recipes = await txn.rawQuery('''
          SELECT material_id, quantity FROM recipes WHERE product_id = ?
        ''', [item.productId]);

        for (final recipe in recipes) {
          final materialId = recipe['material_id'] as String;
          final needQty = (recipe['quantity'] as double) * item.quantity;

          await txn.rawUpdate('''
            UPDATE products 
            SET current_stock = current_stock - ? 
            WHERE id = ?
          ''', [needQty, materialId]);
        }
      }
    });

    return orderId;
  }

  /// Lấy danh sách đơn hàng theo ngày/tháng
  static Future<List<Order>> getOrdersByDate(DateTime start, DateTime end) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT * FROM orders 
      WHERE created_at BETWEEN ? AND ?
      ORDER BY created_at DESC
    ''', [start.toIso8601String(), end.toIso8601String()]);

    return result.map((e) => Order.fromMap(e)).toList();
  }

  /// Lấy chi tiết sản phẩm trong đơn hàng
  static Future<List<OrderItem>> getOrderItems(String orderId) async {
    final db = await _db.database;
    final result = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return result.map((e) => OrderItem.fromMap(e)).toList();
  }

  /// Hủy đơn hàng + hoàn trả kho
  static Future<int> cancelOrder(String orderId) async {
    final db = await _db.database;
    int effectCount = 0;

    await db.transaction((txn) async {
      // Cập nhật trạng thái đơn
      effectCount = await txn.update(
        'orders',
        {'payment_status': 'cancelled'},
        where: 'id = ?',
        whereArgs: [orderId],
      );

      // Hoàn trả sản phẩm & nguyên liệu
      final items = await getOrderItems(orderId);
      for (var item in items) {
        await txn.rawUpdate('''
          UPDATE products SET current_stock = current_stock + ? WHERE id = ?
        ''', [item.quantity, item.productId]);

        final recipes = await txn.rawQuery('''
          SELECT material_id, quantity FROM recipes WHERE product_id = ?
        ''', [item.productId]);
        for (var r in recipes) {
          await txn.rawUpdate('''
            UPDATE products SET current_stock = current_stock + ? WHERE id = ?
          ''', [(r['quantity'] as double) * item.quantity, r['material_id']]);
        }
      }
    });

    return effectCount;
  }

  /// Thống kê doanh thu theo loại đơn hàng
  static Future<Map<String, double>> getRevenueByOrderType(DateTime month) async {
    final db = await _db.database;
    final start = DateTime(month.year, month.month, 1).toIso8601String();
    final end = DateTime(month.year, month.month + 1, 1).toIso8601String();

    final result = await db.rawQuery('''
      SELECT order_type, SUM(total_amount) as total 
      FROM orders 
      WHERE created_at BETWEEN ? AND ? AND payment_status = 'paid'
      GROUP BY order_type
    ''', [start, end]);

    return {for (var r in result) r['order_type'] as String: (r['total'] as double? ?? 0)};
  }
}