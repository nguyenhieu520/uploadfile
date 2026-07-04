import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../../../utils/export/misa_export_service.dart';

class MisaExportScreen extends StatefulWidget {
  const MisaExportScreen({super.key});

  @override
  State<MisaExportScreen> createState() => _MisaExportScreenState();
}

class _MisaExportScreenState extends State<MisaExportScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _isExporting = false;

  // Dữ liệu mẫu - bạn sẽ thay bằng dữ liệu lấy từ CSDL thật
  final List<Map<String, dynamic>> _sampleInventoryData = [
    {
      "product_code": "NL001",
      "product_name": "Cà phê hạt Robusta",
      "unit": "kg",
      "begin_qty": 15.5,
      "begin_value": 3100000,
      "import_qty": 50,
      "import_value": 10000000,
      "export_qty": 42,
      "export_value": 8400000,
      "end_qty": 23.5,
      "end_value": 4700000,
    },
    {
      "product_code": "NL002",
      "product_name": "Sữa đặc Ông Thọ",
      "unit": "lon",
      "begin_qty": 120,
      "begin_value": 1800000,
      "import_qty": 300,
      "import_value": 4500000,
      "export_qty": 280,
      "export_value": 4200000,
      "end_qty": 140,
      "end_value": 2100000,
    }
  ];

  final List<Map<String, dynamic>> _sampleSalaryData = [
    {
      "staff_code": "NV001",
      "full_name": "Nguyễn Văn A",
      "position": "Quản lý",
      "join_date": "2024-01-15",
      "work_days": 26,
      "overtime_hours": 8,
      "salary_basic": 8000000,
      "salary_by_day": 7230769,
      "overtime_money": 553846,
      "allowance": 1000000,
      "total_income": 8784615,
      "bhxh": 702769,
      "bhyt": 131769,
      "piti": 150000,
      "net_salary": 7799077,
    },
    {
      "staff_code": "NV002",
      "full_name": "Trần Thị B",
      "position": "Nhân viên bán hàng",
      "join_date": "2024-03-01",
      "work_days": 24,
      "overtime_hours": 4,
      "salary_basic": 4500000,
      "salary_by_day": 4153846,
      "overtime_money": 230769,
      "allowance": 300000,
      "total_income": 4684615,
      "bhxh": 374769,
      "bhyt": 70269,
      "piti": 50000,
      "net_salary": 4189577,
    }
  ];

  Future<void> _exportInventory() async {
    setState(() => _isExporting = true);
    try {
      final file = await MisaExportService.exportMisaInventoryReport(
        inventoryData: _sampleInventoryData,
        reportMonth: _selectedMonth,
      );
      _showSuccessDialog(file, "Báo cáo xuất nhập tồn");
    } catch (e) {
      _showErrorDialog(e.toString());
    }
    setState(() => _isExporting = false);
  }

  Future<void> _exportSalary() async {
    setState(() => _isExporting = true);
    try {
      final file = await MisaExportService.exportMisaSalaryReport(
        salaryData: _sampleSalaryData,
        salaryMonth: _selectedMonth,
      );
      _showSuccessDialog(file, "Bảng lương");
    } catch (e) {
      _showErrorDialog(e.toString());
    }
    setState(() => _isExporting = false);
  }

  void _showSuccessDialog(File file, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xuất file thành công ✅"),
        content: Text("$type theo chuẩn Misa đã được lưu tại:\n${file.path}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              OpenFile.open(file.path);
            },
            child: const Text("Mở file ngay"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Lỗi xuất file: $error"), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xuất báo cáo chuẩn Misa")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chọn kỳ báo cáo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text("Kỳ báo cáo: ", style: TextStyle(fontSize: 16)),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedMonth,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _selectedMonth = picked);
                      },
                      child: Text(
                        DateFormat('MM/yyyy').format(_selectedMonth),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nút xuất báo cáo
            if (_isExporting)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.inventory_2),
                label: const Text("XUẤT BÁO CÁO XUẤT NHẬP TỒN KHO", style: TextStyle(fontSize: 15)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _exportInventory,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.payments),
                label: const Text("XUẤT BẢNG CÔNG & BẢNG LƯƠNG", style: TextStyle(fontSize: 15)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _exportSalary,
              ),
            ],
            const Spacer(),
            const Text(
              "✅ File xuất ra hoàn toàn tương thích để nhập trực tiếp vào phần mềm Misa",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green, fontSize: 13),
            )
          ],
        ),
      ),
    );
  }
}