import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../models/attendance.dart';

class AttendanceDao {
  static Future<String> checkIn(String staffId) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().toIso8601String();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    // Thêm vào đầu hàm createOrder
    await FirebaseSyncService.instance.queue('orders', order.toMap());
    // Sau khi lưu xong các item
    for (final item in items) {
        await FirebaseSyncService.instance.queue('order_items', item.toMap());
    }
    await db.insert('attendance', {
      'id': id,
      'staff_id': staffId,
      'check_in': now,
      'status': 'present',
    });
    return id;
  }

  static Future<int> checkOut(String attendanceId) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().toIso8601String();
    return await db.update(
      'attendance',
      {'check_out': now, 'work_hours': 8},
      where: 'id = ?',
      whereArgs: [attendanceId],
    );
  }

  static Future<List<Attendance>> getByMonth(String staffId, int month, int year) async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery('''
      SELECT * FROM attendance 
      WHERE staff_id = ? AND strftime('%m', check_in) = ? AND strftime('%Y', check_in) = ?
    ''', [staffId, month.toString().padLeft(2, '0'), year.toString()]);
    return result.map((e) => Attendance.fromMap(e)).toList();
  }
}