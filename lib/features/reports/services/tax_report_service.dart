import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class TaxReportService {
  /// Xuất báo cáo thuế GTGT (VAT) theo chuẩn Tổng cục Thuế
  static Future<File> exportVatReport(DateTime period) async {
    final excel = Excel.createExcel();
    final sheet = excel['BaoCaoThueGTGT'];

    sheet.appendRow(['BÁO CÁO KHAI THUẾ GIÁ TRỊ GIA TĂNG']);
    sheet.appendRow(['Kỳ tính thuế: Tháng ${period.month} năm ${period.year}']);
    sheet.appendRow([]);
    sheet.appendRow([
      'STT', 'Mã loại HHDV', 'Doanh thu chưa thuế', 'Thuế suất GTGT', 'Số thuế GTGT phải nộp'
    ]);

    // Dữ liệu mẫu
    sheet.appendRow(['1', 'Hàng hóa, dịch vụ 10%', '40.000.000', '10%', '4.000.000']);
    sheet.appendRow(['2', 'Hàng hóa, dịch vụ 5%', '5.200.000', '5%', '260.000']);
    sheet.appendRow(['Tổng cộng', '', '45.200.000', '', '4.260.000']);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/BaoCaoThueGTGT_${period.month}_${period.year}.xlsx');
    await file.writeAsBytes(excel.encode()!);
    return file;
  }
}