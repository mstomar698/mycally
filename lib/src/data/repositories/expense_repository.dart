import 'package:isar/isar.dart';
import 'package:mycally/src/data/models/expense.dart';
import 'package:mycally/src/data/models/expense_analytics.dart';
import 'package:mycally/src/data/services/database.dart';

class ExpenseRepository {
  ExpenseRepository({Isar? isarInstance}) : _isar = isarInstance ?? isar;

  final Isar _isar;

  static DateTime dayOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<Expense> create({
    required double amount,
    required DateTime date,
    int? vendorId,
    String? note,
    String? receiptImagePath,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expense = Expense()
      ..amount = amount
      ..date = dayOnly(date)
      ..vendorId = vendorId
      ..note = note
      ..receiptImagePath = receiptImagePath
      ..createdAt = now
      ..updatedAt = now;

    await _isar.writeTxn(() async {
      await _isar.expenses.put(expense);
    });
    return expense;
  }

  Future<Expense?> getById(int id) => _isar.expenses.get(id);

  Future<List<Expense>> getByDay(DateTime date) {
    final start = dayOnly(date);
    final end = start.add(const Duration(days: 1));
    return _isar.expenses
        .filter()
        .dateGreaterThan(start.subtract(const Duration(microseconds: 1)))
        .dateLessThan(end)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<Expense>> getByMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return _isar.expenses
        .filter()
        .dateGreaterThan(start.subtract(const Duration(microseconds: 1)))
        .dateLessThan(end)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<Expense>> getByCategory(int vendorId) => _isar.expenses
      .filter()
      .vendorIdEqualTo(vendorId)
      .sortByDateDesc()
      .findAll();

  Future<double> totalForMonth(int year, int month) async {
    final expenses = await getByMonth(year, month);
    return expenses.fold<double>(0, (sum, e) => sum + e.amount);
  }

  Future<double> totalForDay(DateTime date) async {
    final expenses = await getByDay(date);
    return expenses.fold<double>(0, (sum, e) => sum + e.amount);
  }

  Future<Set<DateTime>> daysWithExpensesInMonth(int year, int month) async {
    final expenses = await getByMonth(year, month);
    return expenses.map((e) => dayOnly(e.date)).toSet();
  }

  Future<List<Expense>> getByDateRange(DateTime start, DateTime end) {
    final rangeStart = dayOnly(start);
    final rangeEnd = dayOnly(end).add(const Duration(days: 1));
    return _isar.expenses
        .filter()
        .dateGreaterThan(rangeStart.subtract(const Duration(microseconds: 1)))
        .dateLessThan(rangeEnd)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<CategoryTotal>> categoryTotalsForMonth(int year, int month) async {
    final expenses = await getByMonth(year, month);
    final totals = <int?, double>{};
    for (final expense in expenses) {
      totals[expense.vendorId] = (totals[expense.vendorId] ?? 0) + expense.amount;
    }
    return totals.entries
        .map((e) => CategoryTotal(vendorId: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  Future<List<DailyTotal>> dailyTotalsForMonth(int year, int month) async {
    final expenses = await getByMonth(year, month);
    final totals = <DateTime, double>{};
    for (final expense in expenses) {
      final day = dayOnly(expense.date);
      totals[day] = (totals[day] ?? 0) + expense.amount;
    }
    final days = totals.keys.toList()..sort();
    return days
        .map((day) => DailyTotal(date: day, amount: totals[day]!))
        .toList();
  }

  Future<List<MonthTotal>> monthTotalsEndingAt(int year, int month, int count) async {
    final results = <MonthTotal>[];
    var cursor = DateTime(year, month, 1);
    for (var i = 0; i < count; i++) {
      final total = await totalForMonth(cursor.year, cursor.month);
      results.add(MonthTotal(year: cursor.year, month: cursor.month, amount: total));
      cursor = DateTime(cursor.year, cursor.month - 1, 1);
    }
    return results.reversed.toList();
  }

  Future<ExpenseReportSummary> reportSummary({
    required DateTime start,
    required DateTime end,
    required Map<int?, String> categoryLabels,
    int largestLimit = 5,
  }) async {
    final expenses = await getByDateRange(start, end);
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final daySpan = dayOnly(end).difference(dayOnly(start)).inDays + 1;
    final dailyAverage = daySpan > 0 ? total / daySpan : 0.0;

    final categoryMap = <int?, double>{};
    for (final expense in expenses) {
      categoryMap[expense.vendorId] =
          (categoryMap[expense.vendorId] ?? 0) + expense.amount;
    }
    final categoryTotals = categoryMap.entries
        .map((e) => CategoryTotal(vendorId: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final sorted = List<Expense>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final largest = sorted.take(largestLimit).map((expense) {
      final label = categoryLabels[expense.vendorId] ?? 'uncategorized';
      return (label: label, amount: expense.amount, date: expense.date);
    }).toList();

    return ExpenseReportSummary(
      total: total,
      transactionCount: expenses.length,
      dailyAverage: dailyAverage,
      categoryTotals: categoryTotals,
      largestExpenses: largest,
    );
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.expenses.delete(id);
    });
  }

  Future<Expense> update(Expense expense) async {
    expense.updatedAt = DateTime.now().millisecondsSinceEpoch;
    await _isar.writeTxn(() async {
      await _isar.expenses.put(expense);
    });
    return expense;
  }
}
