import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isScanning = false;
  String? _lastScanResult;
  final DateFormat _timeFormat = DateFormat('HH:mm:ss dd/MM/yyyy');

  Future<void> _processAttendance(String type) async {
    // Ở đây sẽ gọi hàm lưu vào CSDL & đồng bộ lên máy chủ
    setState(() {
      _lastScanResult = '$type thành công lúc ${_timeFormat.format(DateTime.now())}';
      _isScanning = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$_lastScanResult')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chấm công')),
      body: Column(
        children: [
          Expanded(
            child: _isScanning
                ? MobileScanner(
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue == 'STORE_CHECKIN_QR_2026') {
                          _processAttendance('Check-in');
                        } else if (barcode.rawValue == 'STORE_CHECKOUT_QR_2026') {
                          _processAttendance('Check-out');
                        }
                      }
                    },
                  )
                : const Center(child: Text('Nhấn nút bên dưới để quét mã chấm công')),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('CHECK-IN'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () => setState(() => _isScanning = true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('CHECK-OUT'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () => setState(() => _isScanning = true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}