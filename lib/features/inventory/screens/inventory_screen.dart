import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inventory_item.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<InventoryItem> _items = [
    InventoryItem(id: '1', code: 'NL001', name: 'Cà phê hạt Robusta', unit: 'kg', stock: 23.5, minStock: 10, importPrice: 200000),
    InventoryItem(id: '2', code: 'NL002', name: 'Sữa đặc Ông Thọ', unit: 'lon', stock: 140, minStock: 50, importPrice: 15000),
    InventoryItem(id: '3', code: 'HH001', name: 'Nước ngọt Coca', unit: 'chai', stock: 8, minStock: 20, importPrice: 8000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QUẢN LÝ KHO HÀNG'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showImportDialog()),
          IconButton(icon: const Icon(Icons.file_download), onPressed: () => _exportReport()),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final item = _items[i];
          final isLowStock = item.stock < item.minStock;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isLowStock ? Colors.red.shade100 : Colors.green.shade100,
              child: Icon(isLowStock ? Icons.warning : Icons.inventory, color: isLowStock ? Colors.red : Colors.green),
            ),
            title: Text('${item.code} - ${item.name}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tồn kho: ${item.stock} ${item.unit} | Giá nhập: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(item.importPrice)}'),
                if (isLowStock) const Text('⚠️ Sắp hết hàng, cần nhập thêm!', style: TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.input, size: 18),
                  label: const Text('Nhập'),
                  onPressed: () => _showImportItemDialog(item),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.output, size: 18),
                  label: const Text('Xuất'),
                  onPressed: () => _showExportItemDialog(item),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showImportDialog() { /* Thêm hàng mới */ }
  void _showImportItemDialog(InventoryItem item) { /* Nhập thêm hàng */ }
  void _showExportItemDialog(InventoryItem item) { /* Xuất hàng */ }
  void _exportReport() { /* Gọi hàm xuất file Misa đã tạo ở trên */ }
}