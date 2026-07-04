import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CafePro Manager - Trang Chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chào mừng ${user?.email ?? 'bạn'}!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Chức năng chính:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            // Lưới chức năng
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    icon: Icons.point_of_sale,
                    title: 'Bán hàng (POS)',
                    color: Colors.orange,
                    route: '/pos',
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.inventory_2,
                    title: 'Quản lý kho',
                    color: Colors.green,
                    route: '/inventory',
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.people,
                    title: 'Chấm công',
                    color: Colors.blue,
                    route: '/attendance',
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.payments,
                    title: 'Tính lương',
                    color: Colors.purple,
                    route: '/salary',
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Báo cáo',
                    color: Colors.brown,
                    route: '/reports',
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.file_export,
                    title: 'Xuất Misa',
                    color: Colors.teal,
                    route: '/misa-export',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}