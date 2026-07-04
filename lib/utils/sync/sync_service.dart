import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/database/app_database.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  static SupabaseClient? _supabase;
  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;

  SyncService._init();

  /// Khởi tạo kết nối máy chủ đồng bộ
  Future<void> init() async {
    await Supabase.initialize(
      url: 'https://your-project.supabase.co',
      anonKey: 'your-anon-key',
    );
    _supabase = Supabase.instance.client;

    // Lắng nghe trạng thái mạng -> tự động đồng bộ khi có internet
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) syncAllData();
    });
  }

  /// Lấy danh sách thay đổi cục bộ chưa đồng bộ
  Future<List<Map<String, dynamic>>> _getPendingChanges() async {
    final db = await AppDatabase.instance.database;
    return await db.rawQuery('''
      SELECT * FROM sync_queue WHERE synced = 0 ORDER BY created_at ASC
    ''');
  }

  /// Đồng bộ tất cả dữ liệu
  Future<void> syncAllData() async {
    if (_isSyncing || _supabase == null) return;
    _isSyncing = true;

    try {
      // 1. Đẩy dữ liệu cục bộ lên máy chủ
      final pending = await _getPendingChanges();
      for (final change in pending) {
        await _supabase!.from(change['table_name']).upsert({
          ...change['data'],
          'updated_at': DateTime.now().toIso8601String(),
        });
        // Đánh dấu đã đồng bộ
        final db = await AppDatabase.instance.database;
        await db.update('sync_queue', {'synced': 1}, where: 'id = ?', whereArgs: [change['id']]);
      }

      // 2. Kéo dữ liệu mới nhất từ máy chủ về
      final remoteOrders = await _supabase!.from('orders').select().gte('updated_at', _getLastSyncTime());
      final db = await AppDatabase.instance.database;
      for (final order in remoteOrders) {
        await db.insert('orders', order, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      _showSyncSuccess();
    } catch (e) {
      print('Lỗi đồng bộ: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Thêm thay đổi vào hàng đợi đồng bộ
  Future<void> queueChange(String table, Map<String, dynamic> data) async {
    final db = await AppDatabase.instance.database;
    await db.insert('sync_queue', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'table_name': table,
      'data': data,
      'synced': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
    // Tự động đồng bộ ngay nếu có mạng
    if (await Connectivity().checkConnectivity() != ConnectivityResult.none) {
      syncAllData();
    }
  }

  void _showSyncSuccess() {
    // Hiển thị thông báo cho người dùng
  }

  void dispose() {
    _connectivitySub?.cancel();
  }
}