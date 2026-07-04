import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// Dịch vụ xuất file theo chuẩn định dạng Misa Việt Nam
class MisaExportService {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '');

  // ==============================================
  // 1. BÁO CÁO XUẤT NHẬP TỒN KHO - CHUẨN MISA
  // ==============================================
  static Future<File> exportMisaInventoryReport({
    required List<Map<String, dynamic>> inventoryData,
    required DateTime reportMonth,
  }) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['XuatNhapTon'];

    // Tiêu đề báo cáo - truyền trực tiếp giá trị
    sheet.appendRow(['CÔNG TY / CỬA HÀNG CAFE']);
    sheet.appendRow(['BÁO CÁO TÌNH HÌNH XUẤT NHẬP TỒN KHO']);
    sheet.appendRow(['Kỳ báo cáo: Tháng ${reportMonth.month} / ${reportMonth.year}']);
    sheet.appendRow(['Ngày xuất: ${_dateFormat.format(DateTime.now())}']);
    sheet.appendRow([]);

    // Cột dữ liệu chuẩn Misa
    sheet.appendRow([
      'STT',
      'Mã vật tư/hàng hóa',
      'Tên vật tư/hàng hóa',
      'Đơn vị tính',
      'Số lượng tồn đầu kỳ',
      'Trị giá tồn đầu kỳ',
      'Số lượng nhập trong kỳ',
      'Trị giá nhập trong kỳ',
      'Số lượng xuất trong kỳ',
      'Trị giá xuất trong kỳ',
      'Số lượng tồn cuối kỳ',
      'Trị giá tồn cuối kỳ',
      'Ghi chú'
    ]);

    // Định dạng tiêu đề - đúng tên tham số & giá trị
    final headerStyle = CellStyle(
      backgroundColorHex: '#E6F2FF',
      horizontalAlign: HorizontalAlign.Center,
      bold: true,
    );
    for (int col = 0; col < 13; col++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 5)).cellStyle = headerStyle;
    }

    // Thêm dữ liệu
    int stt = 1;
    double totalBeginValue = 0;
    double totalImportValue = 0;
    double totalExportValue = 0;
    double totalEndValue = 0;

    for (final item in inventoryData) {
      final beginQty = (item['begin_qty'] ?? 0).toDouble();
      final beginValue = (item['begin_value'] ?? 0).toDouble();
      final importQty = (item['import_qty'] ?? 0).toDouble();
      final importValue = (item['import_value'] ?? 0).toDouble();
      final exportQty = (item['export_qty'] ?? 0).toDouble();
      final exportValue = (item['export_value'] ?? 0).toDouble();
      final endQty = (item['end_qty'] ?? 0).toDouble();
      final endValue = (item['end_value'] ?? 0).toDouble();

      totalBeginValue += beginValue;
      totalImportValue += importValue;
      totalExportValue += exportValue;
      totalEndValue += endValue;

      sheet.appendRow([
        stt++,
        item['product_code'] ?? '',
        item['product_name'] ?? '',
        item['unit'] ?? 'cái',
        beginQty,
        beginValue,
        importQty,
        importValue,
        exportQty,
        exportValue,
        endQty,
        endValue,
        item['note'] ?? ''
      ]);
    }

    // Dòng tổng cộng
    sheet.appendRow([
      'Tổng cộng', '', '', '', '',
      totalBeginValue, '',
      totalImportValue, '',
      totalExportValue, '',
      totalEndValue, ''
    ]);

    // Lưu file
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/BaoCaoXuatNhapTon_Misa_${reportMonth.month}_${reportMonth.year}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return file;
  }

  // ==============================================
  // 2. BẢNG CÔNG & BẢNG LƯƠNG - CHUẨN MISA
  // ==============================================
  static Future<File> exportMisaSalaryReport({
    required List<Map<String, dynamic>> salaryData,
    required DateTime salaryMonth,
  }) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['BangLuong'];

    // Tiêu đề báo cáo
    sheet.appendRow(['CỬA HÀNG CAFE']);
    sheet.appendRow(['BẢNG TÍNH LƯƠNG THÁNG ${salaryMonth.month} NĂM ${salaryMonth.year}']);
    sheet.appendRow(['Ngày xuất: ${_dateFormat.format(DateTime.now())}']);
    sheet.appendRow([]);

    // Cột dữ liệu chuẩn Misa
    sheet.appendRow([
      'STT',
      'Mã nhân viên',
      'Họ và tên',
      'Chức vụ',
      'Ngày vào làm',
      'Số ngày công thực tế',
      'Số giờ làm thêm',
      'Lương cơ bản',
      'Lương theo ngày công',
      'Tiền làm thêm',
      'Phụ cấp',
      'Tổng thu nhập',
      'Bảo hiểm xã hội (8%)',
      'Bảo hiểm y tế (1.5%)',
      'Thuế TNCN',
      'Các khoản khấu trừ khác',
      'Thực nhận lương',
      'Ghi chú'
    ]);

    // Định dạng tiêu đề
    final headerStyle = CellStyle(
      backgroundColorHex: '#E6F2FF',
      horizontalAlign: HorizontalAlign.Center,
      bold: true,
    );
    for (int col = 0; col < 18; col++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 4)).cellStyle = headerStyle;
    }

    // Thêm dữ liệu
    int stt = 1;
    double totalBasic = 0;
    double totalIncome = 0;
    double totalDeduction = 0;
    double totalNet = 0;

    for (final emp in salaryData) {
      final basic = (emp['salary_basic'] ?? 0).toDouble();
      final income = (emp['total_income'] ?? 0).toDouble();
      final deduction = (emp['total_deduction'] ?? 0).toDouble();
      final net = (emp['net_salary'] ?? 0).toDouble();

      totalBasic += basic;
      totalIncome += income;
      totalDeduction += deduction;
      totalNet += net;

      sheet.appendRow([
        stt++,
        emp['staff_code'] ?? '',
        emp['full_name'] ?? '',
        emp['position'] ?? 'Nhân viên',
        emp['join_date'] != null ? _dateFormat.format(DateTime.parse(emp['join_date'])) : '',
        (emp['work_days'] ?? 0).toDouble(),
        (emp['overtime_hours'] ?? 0).toDouble(),
        basic,
        (emp['salary_by_day'] ?? 0).toDouble(),
        (emp['overtime_money'] ?? 0).toDouble(),
        (emp['allowance'] ?? 0).toDouble(),
        income,
        (emp['bhxh'] ?? 0).toDouble(),
        (emp['bhyt'] ?? 0).toDouble(),
        (emp['piti'] ?? 0).toDouble(),
        (emp['other_deduction'] ?? 0).toDouble(),
        net,
        emp['note'] ?? ''
      ]);
    }

    // Dòng tổng cộng
    sheet.appendRow([
      'Tổng cộng', '', '', '', '', '', '',
      totalBasic, '', '', '',
      totalIncome, '', '', '', '',
      totalNet, ''
    ]);

    // Lưu file
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/BangLuong_Misa_${salaryMonth.month}_${salaryMonth.year}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return file;
  }
}