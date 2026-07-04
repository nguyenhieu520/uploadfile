import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cafe_pro_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // ==================== TẤT CẢ BẢNG DỮ LIỆU ====================
  Future _createDB(Database db, int version) async {
    // 1. Bảng người dùng & nhân viên
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        data TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        full_name TEXT NOT NULL,
        phone TEXT,
        position TEXT NOT NULL, -- 'admin', 'manager', 'staff', 'warehouse'
        salary_basic REAL NOT NULL DEFAULT 0,
        allowance REAL NOT NULL DEFAULT 0,
        join_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // 2. Bảng danh mục sản phẩm
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE, -- 'Đồ uống', 'Ăn sáng', 'Ăn vặt', 'Tạp hóa'
        description TEXT
      );
    ''');

    // 3. Bảng sản phẩm & nguyên liệu
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        code TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        category_id TEXT NOT NULL,
        sale_price REAL NOT NULL,
        import_price REAL NOT NULL,
        unit TEXT NOT NULL,
        min_stock REAL NOT NULL DEFAULT 0,
        current_stock REAL NOT NULL DEFAULT 0,
        is_raw_material INTEGER NOT NULL DEFAULT 0, -- 0: hàng bán, 1: nguyên liệu
        image_path TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      );
    ''');

    // 4. Bảng công thức chế biến (nguyên liệu cho 1 sản phẩm)
    await db.execute('''
      CREATE TABLE recipes (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        material_id TEXT NOT NULL,
        quantity REAL NOT NULL, -- lượng nguyên liệu cần cho 1 đơn vị sản phẩm
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (material_id) REFERENCES products(id)
      );
    ''');

    // 5. Bảng đơn hàng
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        order_code TEXT UNIQUE NOT NULL,
        order_type TEXT NOT NULL, -- 'Ngồi lại', 'Mang đi', 'Giao hàng'
        table_number TEXT,
        staff_id TEXT NOT NULL,
        total_amount REAL NOT NULL,
        payment_method TEXT NOT NULL, -- 'Tiền mặt', 'Chuyển khoản', 'Ví điện tử'
        payment_status TEXT NOT NULL DEFAULT 'paid', -- 'pending', 'paid', 'cancelled'
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (staff_id) REFERENCES users(id)
      );
    ''');

    // 6. Bảng chi tiết đơn hàng
    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        note TEXT,
        FOREIGN KEY (order_id) REFERENCES orders(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      );
    ''');

    // 7. Bảng nhập xuất kho
    await db.execute('''
      CREATE TABLE inventory_transactions (
        id TEXT PRIMARY KEY,
        code TEXT UNIQUE NOT NULL,
        type TEXT NOT NULL, -- 'import', 'export', 'adjust', 'return'
        product_id TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        supplier TEXT,
        note TEXT,
        staff_id TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (staff_id) REFERENCES users(id)
      );
    ''');

    // 8. Bảng chấm công
    await db.execute('''
      CREATE TABLE attendance (
        id TEXT PRIMARY KEY,
        staff_id TEXT NOT NULL,
        check_in TEXT NOT NULL,
        check_out TEXT,
        work_hours REAL,
        overtime_hours REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL, -- 'present', 'late', 'early_leave', 'absent', 'leave'
        note TEXT,
        FOREIGN KEY (staff_id) REFERENCES users(id)
      );
    ''');

    // 9. Bảng bảng lương
    await db.execute('''
      CREATE TABLE salaries (
        id TEXT PRIMARY KEY,
        staff_id TEXT NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        work_days REAL NOT NULL,
        total_income REAL NOT NULL,
        bhxh REAL NOT NULL,
        bhyt REAL NOT NULL,
        bhtn REAL NOT NULL,
        piti REAL NOT NULL,
        total_deduction REAL NOT NULL,
        net_salary REAL NOT NULL,
        is_paid INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (staff_id) REFERENCES users(id),
        UNIQUE(staff_id, month, year)
      );
    ''');

    // 10. Bảng chi phí
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        code TEXT UNIQUE NOT NULL,
        type TEXT NOT NULL, -- 'rent', 'electric', 'water', 'material', 'other'
        amount REAL NOT NULL,
        description TEXT,
        expense_date TEXT NOT NULL,
        staff_id TEXT NOT NULL,
        FOREIGN KEY (staff_id) REFERENCES users(id)
      );
    ''');

    // ========== DỮ LIỆU MẪU KHỞI TẠO ==========
    await _insertSampleData(db);
  }

  Future _insertSampleData(Database db) async {
    // Thêm danh mục
    await db.insert('categories', [
      {'id': 'CAT001', 'name': 'Đồ uống'},
      {'id': 'CAT002', 'name': 'Ăn sáng'},
      {'id': 'CAT003', 'name': 'Ăn vặt'},
      {'id': 'CAT004', 'name': 'Tạp hóa'},
    ]);

    // Thêm tài khoản quản trị mặc định
    await db.insert('users', {
      'id': 'ADMIN001',
      'username': 'admin',
      'password': '123456',
      'full_name': 'Quản trị viên hệ thống',
      'position': 'admin',
      'salary_basic': 10000000,
      'join_date': '2024-01-01',
    });

    // Thêm sản phẩm mẫu
    await db.insert('products', [
      {'id': 'SP001', 'code': 'CF001', 'name': 'Cà phê sữa đá', 'category_id': 'CAT001', 'sale_price': 25000, 'import_price': 8000, 'unit': 'ly', 'min_stock': 0, 'current_stock': 0, 'is_raw_material': 0},
      {'id': 'SP002', 'code': 'BM001', 'name': 'Bánh mì thịt', 'category_id': 'CAT002', 'sale_price': 20000, 'import_price': 12000, 'unit': 'cái', 'min_stock': 5, 'current_stock': 15, 'is_raw_material': 0},
      {'id': 'NL001', 'code': 'CPH001', 'name': 'Cà phê hạt Robusta', 'category_id': 'CAT001', 'sale_price': 0, 'import_price': 200000, 'unit': 'kg', 'min_stock': 10, 'current_stock': 23.5, 'is_raw_material': 1},
    ]);
  }

  // Đóng CSDL
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}