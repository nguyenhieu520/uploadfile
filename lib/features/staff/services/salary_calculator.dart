import 'package:intl/intl.dart';
import '../models/attendance_record.dart';
import '../models/staff.dart';

class SalaryCalculator {
  static Map<String, dynamic> calculateSalary({
    required Staff staff,
    required List<AttendanceRecord> attendance,
    required DateTime month,
  }) {
    // Tính ngày công thực tế
    final workDays = attendance.where((a) => a.isPresent).length;
    final totalOvertime = attendance.fold<double>(0, (sum, a) => sum + (a.overtimeHours ?? 0));

    // Lương theo quy định Việt Nam
    final dailySalary = staff.salaryBasic / 26;
    final salaryByDay = dailySalary * workDays;
    final overtimeMoney = (dailySalary / 8) * 1.5 * totalOvertime; // Lương làm thêm x1.5
    final totalIncome = salaryByDay + overtimeMoney + staff.allowance;

    // Các khoản khấu trừ
    final bhxh = totalIncome * 0.08;
    final bhyt = totalIncome * 0.015;
    final bhtn = totalIncome * 0.01;
    final taxableIncome = totalIncome - bhxh - bhyt - bhtn - 11000000 - (staff.dependents * 4400000);
    final piti = taxableIncome > 0 ? taxableIncome * 0.05 : 0;
    final totalDeduction = bhxh + bhyt + bhtn + piti;
    final netSalary = totalIncome - totalDeduction;

    return {
      'staff_code': staff.code,
      'full_name': staff.fullName,
      'work_days': workDays,
      'overtime_hours': totalOvertime,
      'salary_basic': staff.salaryBasic,
      'salary_by_day': salaryByDay,
      'overtime_money': overtimeMoney,
      'allowance': staff.allowance,
      'total_income': totalIncome,
      'bhxh': bhxh,
      'bhyt': bhyt,
      'bhtn': bhtn,
      'piti': piti,
      'total_deduction': totalDeduction,
      'net_salary': netSalary,
    };
  }
}