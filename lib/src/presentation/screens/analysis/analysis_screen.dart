import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
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

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final ExpenseRepository _repository = ExpenseRepository();
  late DateTime _focusedMonth;
  bool _loading = true;
  List<CategoryTotal> _categoryTotals = [];
  List<DailyTotal> _dailyTotals = [];
  List<MonthTotal> _monthTotals = [];
  Map<int, Vendor> _vendorsById = {};

  static const _chartColors = [
    Color(0xFF673AB7),
    Color(0xFF9575CD),
    Color(0xFF512DA8),
    Color(0xFFB39DDB),
    Color(0xFF7E57C2),
    Color(0xFF4527A0),
    Color(0xFFD1C4E9),
  ];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final vendors = await isar.vendors.where().anyId().findAll();
    final categoryTotals = await _repository.categoryTotalsForMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final dailyTotals = await _repository.dailyTotalsForMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final monthTotals = await _repository.monthTotalsEndingAt(
      _focusedMonth.year,
      _focusedMonth.month,
      6,
    );
    if (!mounted) return;
    setState(() {
      _vendorsById = {for (final v in vendors) v.id: v};
      _categoryTotals = categoryTotals;
      _dailyTotals = dailyTotals;
      _monthTotals = monthTotals;
      _loading = false;
    });
  }

  String _categoryLabel(int? vendorId) {
    if (vendorId == null) return tr('uncategorized');
    return _vendorsById[vendorId]?.name ?? tr('uncategorized');
  }

  void _shiftMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final backgroundColor =
        settings.themeMode == ThemeMode.dark ? Colors.black : Colors.white;
    final textColor =
        settings.themeMode == ThemeMode.dark ? Colors.white : Colors.deepPurple;
    final fontSize = settings.fontSize;
    final monthLabel = DateFormat.yMMMM(context.locale.toLanguageTag())
        .format(_focusedMonth);

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
                      IconButton(
                        onPressed: () => _shiftMonth(-1),
                        icon: Icon(Icons.chevron_left, color: textColor),
                      ),
                      Expanded(
                        child: Text(
                          monthLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize + 2,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _shiftMonth(1),
                        icon: Icon(Icons.chevron_right, color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _sectionTitle(tr('category_breakdown'), fontSize, textColor),
                  const SizedBox(height: 8),
                  _buildCategoryChart(context, fontSize, textColor),
                  const SizedBox(height: 20),
                  _sectionTitle(tr('daily_spend'), fontSize, textColor),
                  const SizedBox(height: 8),
                  _buildDailyBarChart(fontSize, textColor),
                  const SizedBox(height: 20),
                  _sectionTitle(tr('month_over_month'), fontSize, textColor),
                  const SizedBox(height: 8),
                  _buildMonthBarChart(fontSize, textColor),
                ],
              ),
      ),
    );
  }

  Widget _sectionTitle(String title, double fontSize, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize + 1,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  Widget _buildCategoryChart(
    BuildContext context,
    double fontSize,
    Color textColor,
  ) {
    if (_categoryTotals.isEmpty) {
      return _emptyState(tr('no_expenses_for_analysis'), fontSize, textColor);
    }

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < _categoryTotals.length; i++) {
      final item = _categoryTotals[i];
      sections.add(
        PieChartSectionData(
          value: item.amount,
          color: _chartColors[i % _chartColors.length],
          title: '',
          radius: 52,
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 36,
                  sections: sections,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_categoryTotals.length, (i) {
              final item = _categoryTotals[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _chartColors[i % _chartColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _categoryLabel(item.vendorId),
                        style: TextStyle(fontSize: fontSize - 1),
                      ),
                    ),
                    Text(
                      formatCurrency(context, item.amount),
                      style: TextStyle(
                        fontSize: fontSize - 1,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyBarChart(double fontSize, Color textColor) {
    if (_dailyTotals.isEmpty) {
      return _emptyState(tr('no_expenses_for_analysis'), fontSize, textColor);
    }

    final maxY = _dailyTotals.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: maxY * 1.2,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= _dailyTotals.length) {
                        return const SizedBox.shrink();
                      }
                      if (index % 3 != 0 && _dailyTotals.length > 8) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        '${_dailyTotals[index].date.day}',
                        style: TextStyle(fontSize: fontSize - 4),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(_dailyTotals.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: _dailyTotals[i].amount,
                      color: Colors.deepPurple,
                      width: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthBarChart(double fontSize, Color textColor) {
    if (_monthTotals.every((m) => m.amount == 0)) {
      return _emptyState(tr('no_expenses_for_analysis'), fontSize, textColor);
    }

    final maxY = _monthTotals.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: maxY * 1.2,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= _monthTotals.length) {
                        return const SizedBox.shrink();
                      }
                      final month = _monthTotals[index];
                      return Text(
                        DateFormat.MMM(context.locale.toLanguageTag())
                            .format(DateTime(month.year, month.month)),
                        style: TextStyle(fontSize: fontSize - 4),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(_monthTotals.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: _monthTotals[i].amount,
                      color: Colors.deepPurple.shade300,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String message, double fontSize, Color textColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize - 1,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
