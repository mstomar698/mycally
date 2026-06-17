class CategoryTotal {
  const CategoryTotal({
    required this.vendorId,
    required this.amount,
  });

  final int? vendorId;
  final double amount;
}

class DailyTotal {
  const DailyTotal({
    required this.date,
    required this.amount,
  });

  final DateTime date;
  final double amount;
}

class MonthTotal {
  const MonthTotal({
    required this.year,
    required this.month,
    required this.amount,
  });

  final int year;
  final int month;
  final double amount;
}

class ExpenseReportSummary {
  const ExpenseReportSummary({
    required this.total,
    required this.transactionCount,
    required this.dailyAverage,
    required this.categoryTotals,
    required this.largestExpenses,
  });

  final double total;
  final int transactionCount;
  final double dailyAverage;
  final List<CategoryTotal> categoryTotals;
  final List<({String label, double amount, DateTime date})> largestExpenses;
}
