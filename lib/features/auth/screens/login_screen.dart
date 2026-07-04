import '../../../config/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ctrlUser = TextEditingController(text: 'admin');
    final ctrlPass = TextEditingController(text: '123456');

    return Scaffold(
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.coffee, size: 64, color: Colors.brown),
              const SizedBox(height: 16),
              const Text('Đăng nhập - CafePro Manager', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),

              TextField(
                controller: ctrlUser,
                decoration: const InputDecoration(
                  labelText: 'Tài khoản',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: ctrlPass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              const SizedBox(height: 12),

              // Hiển thị lỗi nếu có
              Consumer<AuthProvider>(
                builder: (context, provider, child) {
                  if (provider.errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final ok = await auth.login(ctrlUser.text.trim(), ctrlPass.text.trim());
                    if (ok && context.mounted) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  child: const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                ),
              ),

              // Nút tạo tài khoản thử (chỉ hiển thị ở chế độ phát triển)
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  final msg = await auth.createAdminAccount('admin', '123456');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: msg == null
                            ? const Text('✅ Tạo tài khoản admin thành công!')
                            : Text('❌ Lỗi tạo tài khoản: $msg'),
                        backgroundColor: msg == null ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Tạo tài khoản admin lần đầu', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}