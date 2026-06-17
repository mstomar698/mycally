import 'package:flutter_test/flutter_test.dart';
import 'package:mycally/src/data/repositories/expense_repository.dart';

void main() {
  test('dayOnly strips time from date', () {
    final date = DateTime(2026, 6, 17, 22, 31, 58);
    final normalized = ExpenseRepository.dayOnly(date);

    expect(normalized.year, 2026);
    expect(normalized.month, 6);
    expect(normalized.day, 17);
    expect(normalized.hour, 0);
    expect(normalized.minute, 0);
  });
}
