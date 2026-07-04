import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class FinanceReportScreen extends StatefulWidget {
  const FinanceReportScreen({super.key});

  @override
  State<FinanceReportScreen> createState() => _FinanceReportScreenState();
}

class _FinanceReportScreenState extends State<FinanceReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BÁO CÁO TÀI CHÍNH')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Thẻ tổng quan
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(children: [
                        Text('Doanh thu tháng', style: TextStyle(fontSize: 14)),
                        SizedBox(height: 8),
                        Text('45.200.000 đ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ]),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.orange.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(children: [
                        Text('Tổng chi phí', style: TextStyle(fontSize: 14)),
                        SizedBox(height: 8),
                        Text('28.700.000 đ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ]),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(children: [
                        Text('Lợi nhuận ròng', style: TextStyle(fontSize: 14)),
                        SizedBox(height: 8),
                        Text('16.500.000 đ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Biểu đồ xu hướng
            SfCartesianChart(
              title: const ChartTitle(text: 'Xu hướng doanh thu 6 tháng gần nhất'),
              primaryXAxis: const CategoryAxis(),
              series: <CartesianSeries>[
                ColumnSeries<SalesData, String>(
                  dataSource: [
                    SalesData('T1', 32000000),
                    SalesData('T2', 38000000),
                    SalesData('T3', 41000000),
                    SalesData('T4', 45200000),
                  ],
                  xValueMapper: (SalesData s, _) => s.month,
                  yValueMapper: (SalesData s, _) => s.revenue,
                  color: Colors.brown,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SalesData {
  final String month;
  final double revenue;
  SalesData(this.month, this.revenue);
}