import 'package:isar/isar.dart';
import 'package:mycally/src/data/models/expense.dart';
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
