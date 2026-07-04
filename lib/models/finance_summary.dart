class FinanceSummary {
  final double totalRevenue;
  final double totalCost;
  final double totalExpense;
  final double grossProfit;
  final double netProfit;

  FinanceSummary({
    required this.totalRevenue,
    required this.totalCost,
    required this.totalExpense,
    required this.grossProfit,
    required this.netProfit,
  });

  factory FinanceSummary.fromMap(Map<String, dynamic> map) => FinanceSummary(
    totalRevenue: (map['total_revenue'] ?? 0).toDouble(),
    totalCost: (map['total_cost'] ?? 0).toDouble(),
    totalExpense: (map['total_expense'] ?? 0).toDouble(),
    grossProfit: (map['gross_profit'] ?? 0).toDouble(),
    netProfit: (map['net_profit'] ?? 0).toDouble(),
  );
}