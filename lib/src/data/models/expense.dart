import 'package:isar/isar.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;

  late double amount;

  /// Calendar day (time component ignored for grouping).
  late DateTime date;

  /// Category/payee — references [Vendor.id].
  int? vendorId;

  String? note;

  String? receiptImagePath;

  late int createdAt;

  late int updatedAt;
}
