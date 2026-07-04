import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../models/user.dart';

class UserDao {
  static Future<User?> login(String username, String password) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ? AND is_active = 1',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  static Future<List<User>> getAllStaff() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query('users', where: 'position != "admin"');
    return result.map((e) => User.fromMap(e)).toList();
  }

  static Future<int> insertUser(User user) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('users', user.toMap());
  }
}