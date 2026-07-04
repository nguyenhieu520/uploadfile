import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/constants.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/models/cart_item.dart';
import '../../product/models/product.dart';
import 'package:intl/intl.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _selectedCategory = 'Tất cả';
  String _orderType = 'Ngồi lại'; // Ngồi lại / Mang đi / Giao hàng

  // Danh sách danh mục theo yêu cầu
  final List<String> _categories = [
    'Tất cả', 'Đồ uống', 'Ăn sáng', 'Ăn vặt', 'Tạp hóa'
  ];

  // Dữ liệu sản phẩm mẫu
  final List<Product> _products = [
    Product(id: '1', name: 'Cà phê sữa đá', price: 25000, category: 'Đồ uống', image: ''),
    Product(id: '2', name: 'Bánh mì thịt', price: 20000, category: 'Ăn sáng', image: ''),
    Product(id: '3', name: 'Khoai tây chiên', price: 15000, category: 'Ăn vặt', image: ''),
    Product(id: '4', name: 'Nước ngọt', price: 10000, category: 'Tạp hóa', image: ''),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final filteredProducts = _selectedCategory == 'Tất cả'
        ? _products
        : _products.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BÁN HÀNG TẠI QUẦY'),
        actions: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Ngồi lại', label: Text('Ngồi lại')),
              ButtonSegment(value: 'Mang đi', label: Text('Mang đi')),
            ],
            selected: {_orderType},
            onSelectionChanged: (sel) => setState(() => _orderType = sel.first),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Danh sách sản phẩm - chiếm 2/3 màn hình
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Lọc danh mục
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) => FilterChip(
                      label: Text(_categories[i]),
                      selected: _selectedCategory == _categories[i],
                      onSelected: (sel) => setState(() => _selectedCategory = _categories[i]),
                    ),
                  ),
                ),
                const Divider(height: 1),
                // Lưới sản phẩm
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (ctx, i) => InkWell(
                      onTap: () => cart.addItem(filteredProducts[i]),
                      borderRadius: BorderRadius.circular(12),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.coffee, size: 40, color: Colors.brown),
                            const SizedBox(height: 8),
                            Text(filteredProducts[i].name, textAlign: TextAlign.center),
                            const SizedBox(height: 4),
                            Text(
                              NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(filteredProducts[i].price),
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Giỏ hàng - chiếm 1/3 màn hình
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(left: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Đơn hàng - $_orderType', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Expanded(
                    child: cart.items.isEmpty
                        ? const Center(child: Text('Chưa có sản phẩm nào'))
                        : ListView.separated(
                            itemCount: cart.items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (ctx, i) {
                              final item = cart.items[i];
                              return ListTile(
                                title: Text(item.product.name),
                                subtitle: Text('${item.quantity} x ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(item.product.price)}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () => cart.decreaseItem(item.product.id),
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, color: Colors.green),
                                      onPressed: () => cart.addItem(item.product),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  // Tổng tiền & nút thanh toán
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng cộng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(cart.totalAmount),
                            style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.green,
                          ),
                          onPressed: cart.items.isEmpty ? null : () => _checkout(cart),
                          child: const Text('THANH TOÁN', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkout(CartProvider cart) {
    // Xử lý lưu đơn, in hóa đơn, trừ kho
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanh toán thành công! Đã in hóa đơn')),
    );
    cart.clear();
  }
}