import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _errorMessage = null;
    try {
      // Tự thêm @cafepro.local cho tên đăng nhập
      final email = username.contains('@') ? username : '$username@cafepro.local';
      
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Lỗi đăng nhập: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Tài khoản không tồn tại! Vui lòng kiểm tra lại hoặc tạo tài khoản trước.';
          break;
        case 'wrong-password':
          _errorMessage = 'Sai mật khẩu! Vui lòng thử lại.';
          break;
        case 'invalid-email':
          _errorMessage = 'Định dạng tài khoản không hợp lệ.';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Chức năng đăng nhập chưa được bật trên Firebase!';
          break;
        case 'user-disabled':
          _errorMessage = 'Tài khoản đã bị khóa.';
          break;
        default:
          _errorMessage = 'Lỗi: ${e.message ?? "Không xác định"}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: $e';
      notifyListeners();
      return false;
    }
  }

  // Hàm tạo tài khoản admin lần đầu (chỉ cần chạy 1 lần)
  Future<String?> createAdminAccount(String username, String password) async {
    try {
      final email = '$username@cafepro.local';
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }
}