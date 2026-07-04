import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../models/finance_summary.dart';

class FinanceDao {
  static final AppDatabase _db = AppDatabase.instance;

  /// Lấy tổng quan tài chính trong kỳ
  static Future<FinanceSummary> getSummary(DateTime startDate, DateTime endDate) async {
    final db = await _db.database;

    // 1. Tổng doanh thu bán hàng
    final revenueResult = await db.rawQuery('''
      SELECT COALESCE(SUM(total_amount), 0) as total 
      FROM orders 
      WHERE created_at BETWEEN ? AND ? AND payment_status = 'paid'
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    final totalRevenue = (revenueResult.first['total'] as double? ?? 0);

    // 2. Tổng giá vốn hàng bán
    final costResult = await db.rawQuery('''
      SELECT COALESCE(SUM(oi.quantity * p.import_price), 0) as total 
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      JOIN orders o ON oi.order_id = o.id
      WHERE o.created_at BETWEEN ? AND ? AND o.payment_status = 'paid'
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    final totalCost = (costResult.first['total'] as double? ?? 0);

    // 3. Tổng chi phí hoạt động
    final expenseResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM expenses 
      WHERE expense_date BETWEEN ? AND ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    final totalExpense = (expenseResult.first['total'] as double? ?? 0);

    // 4. Tổng chi phí lương
    final salaryResult = await db.rawQuery('''
      SELECT COALESCE(SUM(net_salary), 0) as total 
      FROM salaries 
      WHERE year = ? AND month = ?
    ''', [startDate.year, startDate.month]);
    final totalSalary = (salaryResult.first['total'] as double? ?? 0);

    // Tính toán lợi nhuận
    final grossProfit = totalRevenue - totalCost;
    final netProfit = grossProfit - totalExpense - totalSalary;

    return FinanceSummary(
      totalRevenue: totalRevenue,
      totalCost: totalCost,
      totalExpense: totalExpense + totalSalary,
      grossProfit: grossProfit,
      netProfit: netProfit,
    );
  }

  /// Thống kê theo ngày trong tháng (dùng vẽ biểu đồ)
  static Future<List<Map<String, dynamic>>> getDailyRevenue(DateTime month) async {
    final db = await _db.database;
    final start = DateTime(month.year, month.month, 1).toIso8601String();
    final end = DateTime(month.year, month.month + 1, 1).toIso8601String();

    final result = await db.rawQuery('''
      SELECT 
        strftime('%d', created_at) as day,
        SUM(total_amount) as revenue
      FROM orders
      WHERE created_at BETWEEN ? AND ? AND payment_status = 'paid'
      GROUP BY strftime('%d', created_at)
      ORDER BY day
    ''', [start, end]);

    return result;
  }

  /// Thống kê chi phí theo loại
  static Future<Map<String, double>> getExpenseByType(DateTime month) async {
    final db = await _db.database;
    final start = DateTime(month.year, month.month, 1).toIso8601String();
    final end = DateTime(month.year, month.month + 1, 1).toIso8601String();

    final result = await db.rawQuery('''
      SELECT type, SUM(amount) as total 
      FROM expenses 
      WHERE expense_date BETWEEN ? AND ?
      GROUP BY type
    ''', [start, end]);

    final typeMap = {
      'rent': 'Thuê mặt bằng',
      'electric': 'Tiền điện',
      'water': 'Tiền nước',
      'material': 'Mua nguyên liệu',
      'other': 'Chi phí khác',
    };

    return {
      for (var r in result)
        typeMap[r['type']] as String: (r['total'] as double? ?? 0)
    };
  }

  /// Lấy dữ liệu cho báo cáo thuế GTGT
  static Future<Map<String, double>> getVatData(DateTime period) async {
    final db = await _db.database;
    final start = DateTime(period.year, period.month, 1).toIso8601String();
    final end = DateTime(period.year, period.month + 1, 1).toIso8601String();

    final data10 = await db.rawQuery('''
      SELECT COALESCE(SUM(total_amount), 0) as total FROM orders
      WHERE created_at BETWEEN ? AND ? AND payment_status = 'paid'
    ''', [start, end]);

    final doanhThuChuaThue = (data10.first['total'] as double? ?? 0) / 1.1;
    final thue10 = doanhThuChuaThue * 0.1;

    return {
      'doanh_thue_chua_thue': doanhThuChuaThue,
      'thue_gtgt_10': thue10,
      'tong_thue_phai_nop': thue10,
    };
  }
}