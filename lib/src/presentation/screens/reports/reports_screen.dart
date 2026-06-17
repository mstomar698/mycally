import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:mycally/src/data/models/expense_analytics.dart';
import 'package:mycally/src/data/models/vendor.dart';
import 'package:mycally/src/data/repositories/expense_repository.dart';
import 'package:mycally/src/data/services/database.dart';
import 'package:mycally/src/presentation/widgets/pull_to_refresh_wrapper.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:mycally/src/utils/currency_formatter.dart';
import 'package:provider/provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ExpenseRepository _repository = ExpenseRepository();
  late DateTime _rangeStart;
  late DateTime _rangeEnd;
  bool _loading = true;
  ExpenseReportSummary? _summary;
  Map<int?, String> _categoryLabels = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _rangeStart = DateTime(now.year, now.month, 1);
    _rangeEnd = DateTime(now.year, now.month + 1, 0);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final vendors = await isar.vendors.where().anyId().findAll();
    final labels = <int?, String>{
      null: tr('uncategorized'),
      for (final vendor in vendors) vendor.id: vendor.name,
    };
    final summary = await _repository.reportSummary(
      start: _rangeStart,
      end: _rangeEnd,
      categoryLabels: labels,
    );
    if (!mounted) return;
    setState(() {
      _categoryLabels = labels;
      _summary = summary;
      _loading = false;
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _rangeStart, end: _rangeEnd),
    );
    if (picked == null) return;
    setState(() {
      _rangeStart = picked.start;
      _rangeEnd = picked.end;
    });
    await _loadData();
  }

  String _categoryLabel(int? vendorId) =>
      _categoryLabels[vendorId] ?? tr('uncategorized');

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final backgroundColor =
        settings.themeMode == ThemeMode.dark ? Colors.black : Colors.white;
    final textColor =
        settings.themeMode == ThemeMode.dark ? Colors.white : Colors.deepPurple;
    final fontSize = settings.fontSize;
    final rangeLabel =
        '${DateFormat.yMMMd(context.locale.toLanguageTag()).format(_rangeStart)} - ${DateFormat.yMMMd(context.locale.toLanguageTag()).format(_rangeEnd)}';

    return PullToRefreshWrapper(
      onRefresh: _loadData,
      child: Container(
        color: backgroundColor,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tr('reports'),
                          style: TextStyle(
                            fontSize: fontSize + 2,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickDateRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(tr('date_range')),
                      ),
                    ],
                  ),
                  Text(
                    rangeLabel,
                    style: TextStyle(
                      fontSize: fontSize - 1,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCards(context, fontSize, textColor),
                  const SizedBox(height: 20),
                  Text(
                    tr('category_summary'),
                    style: TextStyle(
                      fontSize: fontSize + 1,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCategoryTable(fontSize, textColor),
                  const SizedBox(height: 20),
                  Text(
                    tr('largest_expenses'),
                    style: TextStyle(
                      fontSize: fontSize + 1,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLargestList(context, fontSize, textColor),
                ],
              ),
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    double fontSize,
    Color textColor,
  ) {
    final summary = _summary!;
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            tr('total_spent'),
            formatCurrency(context, summary.total),
            fontSize,
            textColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryCard(
            tr('daily_average'),
            formatCurrency(context, summary.dailyAverage),
            fontSize,
            textColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryCard(
            tr('transactions'),
            '${summary.transactionCount}',
            fontSize,
            textColor,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
    String label,
    String value,
    double fontSize,
    Color textColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: fontSize - 3, color: textColor.withOpacity(0.7)),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTable(double fontSize, Color textColor) {
    final categories = _summary?.categoryTotals ?? [];
    if (categories.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            tr('no_expenses_for_analysis'),
            style: TextStyle(fontSize: fontSize - 1, color: textColor.withOpacity(0.7)),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: categories.map((item) {
          return ListTile(
            title: Text(
              _categoryLabel(item.vendorId),
              style: TextStyle(fontSize: fontSize - 1),
            ),
            trailing: Text(
              NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2)
                  .format(item.amount),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
                fontSize: fontSize - 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLargestList(
    BuildContext context,
    double fontSize,
    Color textColor,
  ) {
    final largest = _summary?.largestExpenses ?? [];
    if (largest.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            tr('no_expenses_for_analysis'),
            style: TextStyle(fontSize: fontSize - 1, color: textColor.withOpacity(0.7)),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: largest.map((item) {
          return ListTile(
            leading: const Icon(Icons.trending_up),
            title: Text(item.label, style: TextStyle(fontSize: fontSize - 1)),
            subtitle: Text(
              DateFormat.yMMMd(context.locale.toLanguageTag()).format(item.date),
              style: TextStyle(fontSize: fontSize - 2),
            ),
            trailing: Text(
              formatCurrency(context, item.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: fontSize - 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
