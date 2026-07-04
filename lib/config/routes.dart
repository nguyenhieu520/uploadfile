import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/pos/screens/pos_screen.dart';
import '../features/inventory/screens/inventory_screen.dart';
import '../features/staff/screens/attendance_screen.dart';
import '../features/staff/screens/salary_screen.dart';
import '../features/reports/screens/finance_report_screen.dart';
import '../features/reports/screens/misa_export_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String pos = '/pos';
  static const String inventory = '/inventory';
  static const String attendance = '/attendance';
  static const String salary = '/salary';
  static const String reports = '/reports';
  static const String misaExport = '/misa-export';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    pos: (context) => const PosScreen(),
    inventory: (context) => const InventoryScreen(),
    attendance: (context) => const AttendanceScreen(),
    salary: (context) => const SalaryScreen(),
    reports: (context) => const FinanceReportScreen(),
    misaExport: (context) => const MisaExportScreen(),
  };
}