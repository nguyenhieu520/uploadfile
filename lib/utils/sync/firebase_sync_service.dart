import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../data/database/app_database.dart';

class FirebaseSyncService {
  static final FirebaseSyncService _instance = FirebaseSyncService._internal();
  factory FirebaseSyncService() => _instance;
  FirebaseSyncService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  bool _isSyncing = false;

  /// Khởi tạo
  Future<void> init() async {
    await Firebase.initializeApp();
    _db.settings = const Settings(persistenceEnabled: true);
    _listenConnectivity();
  }

  /// Lắng nghe mạng → tự động đồng bộ khi có internet
  void _listenConnectivity() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) syncAll();
    });
  }

  /// Đẩy thay đổi cục bộ lên Firebase
  Future<void> _pushLocalChanges() async {
    final localDb = await AppDatabase.instance.database;
    final pending = await localDb.query('sync_queue', where: 'synced = 0');

    for (final row in pending) {
      final table = row['table_name'] as String;
      final data = jsonDecode(row['data'] as String);
      final docId = row['id'] as String;

      await _db.collection(table).doc(docId).set(data, SetOptions(merge: true));
      await localDb.update('sync_queue', {'synced': 1}, where: 'id = ?', whereArgs: [docId]);
    }
  }

  /// Kéo dữ liệu mới từ Firebase về SQLite
  Future<void> _pullRemoteData() async {
    final localDb = await AppDatabase.instance.database;
    final tables = ['users', 'categories', 'products', 'orders', 'inventory_transactions', 'attendance', 'salaries', 'expenses'];

    for (final table in tables) {
      final snapshot = await _db.collection(table).get();
      final batch = localDb.batch();

      for (final doc in snapshot.docs) {
        batch.insert(
          table,
          doc.data(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
  }

  /// Đồng bộ 2 chiều
  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await _pushLocalChanges();
      await _pullRemoteData();
      print('✅ Đồng bộ Firebase thành công');
    } catch (e) {
      print('❌ Lỗi đồng bộ: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Thêm thay đổi vào hàng đợi
  Future<void> queue(String table, Map<String, dynamic> data) async {
    final localDb = await AppDatabase.instance.database;
    await localDb.insert('sync_queue', {
      'id': data['id'],
      'table_name': table,
      'data': jsonEncode(data),
      'synced': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
    // Tự động đồng bộ ngay nếu có mạng
    if (await Connectivity().checkConnectivity() != ConnectivityResult.none) {
      syncAll();
    }
  }

  /// Lắng nghe thay đổi thời gian thực từ Firebase
  void startRealtimeSync() {
    final tables = ['orders', 'products', 'attendance'];
    for (final table in tables) {
      _db.collection(table).snapshots().listen((snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.modified || change.type == DocumentChangeType.added) {
            AppDatabase.instance.database.then((db) => db.insert(
              table,
              change.doc.data()!,
              conflictAlgorithm: ConflictAlgorithm.replace,
            ));
          }
        }
      });
    }
  }
}