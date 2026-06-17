// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:mycally/src/data/models/expense.dart';
import 'package:mycally/src/data/models/user.dart';
import 'package:mycally/src/data/models/vendor.dart';
import 'package:mycally/src/data/repositories/expense_repository.dart';
import 'package:mycally/src/data/services/database.dart';
import 'package:mycally/src/presentation/screens/analysis/analysis_screen.dart';
import 'package:mycally/src/presentation/screens/profile/profile_screen.dart';
import 'package:mycally/src/presentation/screens/reports/reports_screen.dart';
import 'package:mycally/src/presentation/screens/settings/settings_screen.dart';
import 'package:mycally/src/presentation/widgets/pull_to_refresh_wrapper.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:mycally/src/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final ImagePicker _imagePicker = ImagePicker();

  int _currentIndex = 0;
  bool _showCalendar = false;
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Future<User?>? _userFuture;
  List<Expense> _selectedDayExpenses = <Expense>[];
  double _monthTotal = 0;
  Set<DateTime> _daysWithExpenses = <DateTime>{};
  Map<int, Vendor> _vendorsById = <int, Vendor>{};

  @override
  void initState() {
    super.initState();
    _loadUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentIndex();
    });
  }

  void _loadCurrentIndex() {
    final passedCurrentIndex = ModalRoute.of(context)?.settings.arguments;
    if (passedCurrentIndex is int) {
      debugPrint('Editing vendor ID: $passedCurrentIndex');
      setState(() {
        _currentIndex = passedCurrentIndex;
      });
    } else {
      debugPrint('No Id passed, using default index');
      _currentIndex = _currentIndex;
    }
  }

  void _loadUser() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final currentUserId = settingsProvider.currentUserId;

    if (currentUserId != null) {
      _userFuture = isar.users.get(currentUserId);
    } else {
      _userFuture = Future.value(null);
    }
  }

  Future<void> _refresh() async {
    _selectedDate = DateTime.now();
    _loadUser();
    await Future.wait([
      _userFuture ?? Future<void>.value(),
      _loadExpenseState(),
    ]);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleDateSelected(DateTime newDate) async {
    setState(() {
      _selectedDate = newDate;
    });
    await _loadDayExpenses();
    if (mounted) {
      setState(() {});
    }
  }

  void _handleShowCalendarChanged(bool show) {
    setState(() {
      _showCalendar = show;
    });
  }

  void _handleFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  void _handleNavigateToAnalysis() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadExpenseState();
  }

  Future<void> _loadExpenseState() async {
    await Future.wait([_loadVendors(), _loadMonthTotalAndMarkers(), _loadDayExpenses()]);
  }

  Future<void> _loadVendors() async {
    final vendors = await isar.vendors.where().anyId().findAll();
    _vendorsById = <int, Vendor>{for (final vendor in vendors) vendor.id: vendor};
  }

  Future<void> _loadMonthTotalAndMarkers() async {
    final monthTotal =
        await _expenseRepository.totalForMonth(_selectedDate.year, _selectedDate.month);
    final days = await _expenseRepository.daysWithExpensesInMonth(
      _selectedDate.year,
      _selectedDate.month,
    );
    _monthTotal = monthTotal;
    _daysWithExpenses = days;
  }

  Future<void> _loadDayExpenses() async {
    _selectedDayExpenses = await _expenseRepository.getByDay(_selectedDate);
  }

  Future<void> _showAddExpenseSheet() async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int? selectedVendorId;
    String? receiptImagePath;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tr('add_expense'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: tr('amount'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: Validators.validateAmount,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      value: selectedVendorId,
                      decoration: InputDecoration(
                        labelText: tr('category'),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(tr('uncategorized')),
                        ),
                        ..._vendorsById.values.map(
                          (v) => DropdownMenuItem<int?>(
                            value: v.id,
                            child: Text(v.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          selectedVendorId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: tr('note'),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final file = await _imagePicker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (file != null) {
                                setModalState(() {
                                  receiptImagePath = file.path;
                                });
                              }
                            },
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(tr('add_receipt_photo')),
                          ),
                        ),
                      ],
                    ),
                    if (receiptImagePath != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tr('photo_attached'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          await _expenseRepository.create(
                            amount: double.parse(amountController.text.trim()),
                            date: _selectedDate,
                            vendorId: selectedVendorId,
                            note: noteController.text.trim().isEmpty
                                ? null
                                : noteController.text.trim(),
                            receiptImagePath: receiptImagePath,
                          );
                          if (!mounted) {
                            return;
                          }
                          Navigator.of(context).pop();
                          await _loadExpenseState();
                          if (!mounted) {
                            return;
                          }
                          setState(() {});
                        },
                        child: Text(tr('save')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final backgroundColor = settingsProvider.themeMode == ThemeMode.dark
        ? Colors.black
        : Colors.white;
    final textColor = settingsProvider.themeMode == ThemeMode.dark
        ? Colors.white
        : Colors.deepPurple;
    final fontSize = settingsProvider.fontSize;
    final monthTotalLabel = NumberFormat.currency(
      locale: context.locale.toLanguageTag(),
      symbol: '₹',
      decimalDigits: 2,
    ).format(_monthTotal);
    return PullToRefreshWrapper(
      onRefresh: _refresh,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Center(
              child: Text(
                tr('app_name'),
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize + 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          leadingWidth: 150,
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              color: textColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<User?>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  tr('error_loading_profile'),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.red,
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text(
                  tr('no_user_found'),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
              );
            } else {
              final user = snapshot.data!;
              return IndexedStack(
                index: _currentIndex,
                children: [
                  HomePageContent(
                    user: user,
                    selectedDate: _selectedDate,
                    showCalendar: _showCalendar,
                    monthTotalLabel: monthTotalLabel,
                    calendarFormat: _calendarFormat,
                    selectedDayExpenses: _selectedDayExpenses,
                    daysWithExpenses: _daysWithExpenses,
                    vendorsById: _vendorsById,
                    onDateSelected: _handleDateSelected,
                    onFormatChangedTrigger: _handleFormatChanged,
                    onShowCalendarChanged: _handleShowCalendarChanged,
                    handleNavigateToAnalysis: _handleNavigateToAnalysis,
                    onAddExpense: _showAddExpenseSheet,
                  ),
                  const AnalysisScreen(),
                  const ReportsScreen(),
                  const SettingsScreen(),
                ],
              );
            }
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: backgroundColor,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: textColor.withValues(alpha: 0.6),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: tr('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.analytics),
              label: tr('analysis'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.insert_drive_file),
              label: tr('reports'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: tr('settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final User user;
  final bool showCalendar;
  final String monthTotalLabel;
  final DateTime selectedDate;
  final CalendarFormat _calendarFormat;
  final Future<void> Function(DateTime) onDateSelected;
  final ValueChanged<bool> onShowCalendarChanged;
  final ValueChanged<CalendarFormat> onFormatChangedTrigger;
  final VoidCallback handleNavigateToAnalysis;
  final VoidCallback onAddExpense;
  final List<Expense> selectedDayExpenses;
  final Set<DateTime> daysWithExpenses;
  final Map<int, Vendor> vendorsById;

  const HomePageContent({
    super.key,
    required this.user,
    required this.monthTotalLabel,
    required this.selectedDate,
    required this.showCalendar,
    required this.onDateSelected,
    required this.onShowCalendarChanged,
    required this.onFormatChangedTrigger,
    required CalendarFormat calendarFormat,
    required this.handleNavigateToAnalysis,
    required this.onAddExpense,
    required this.selectedDayExpenses,
    required this.daysWithExpenses,
    required this.vendorsById,
  }) : _calendarFormat = calendarFormat;

  Widget _buildMonthYearSelector(BuildContext context, DateTime selectedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<int>(
          value: selectedDate.month,
          onChanged: (int? newMonth) {
            final newDate =
                DateTime(selectedDate.year, newMonth!, selectedDate.day);
            onDateSelected(newDate);
          },
          items: List.generate(12, (index) => index + 1)
              .map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value'),
            );
          }).toList(),
        ),
        DropdownButton<int>(
          value: selectedDate.year,
          onChanged: (int? newYear) {
            final newDate =
                DateTime(newYear!, selectedDate.month, selectedDate.day);
            onDateSelected(newDate);
          },
          items: List.generate(10, (index) => DateTime.now().year - 5 + index)
              .map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCalendar(
      BuildContext context, double fontSize, Color textColor) {
    return Column(
      children: [
        _buildMonthYearSelector(context, selectedDate),
        TableCalendar(
          firstDay: DateTime.utc(2010, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: selectedDate,
          calendarFormat: _calendarFormat, // Add this state variable
          onFormatChanged: (format) {
            onFormatChangedTrigger(format);
          },
          selectedDayPredicate: (day) => isSameDay(day, selectedDate),
          eventLoader: (day) {
            final key = DateTime(day.year, day.month, day.day);
            return daysWithExpenses.contains(key) ? <String>['expense'] : <String>[];
          },
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) async {
            await onDateSelected(selectedDay);
            onShowCalendarChanged(false);
          },
        ),
        TextButton(
          onPressed: () {
            onShowCalendarChanged(false);
          },
          child: Text(
            tr('close_calendar'),
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateScroller(
      BuildContext context, double fontSize, Color textColor) {
    if (showCalendar) {
      return _buildCalendar(context, fontSize, textColor);
    } else {
      final DateTime now = selectedDate;
      final PageController pageController = PageController(initialPage: 1000);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(
              height: 80,
              child: PageView.builder(
                controller: pageController,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index) {},
                itemBuilder: (context, pageIndex) {
                  final DateTime date =
                      now.add(Duration(days: pageIndex - 1000));
                  return _buildDateRow(context, date, fontSize, textColor);
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      onShowCalendarChanged(true);
                    },
                    child: Text(
                      tr('view_all'),
                      style: TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDateRow(
      BuildContext context, DateTime date, double fontSize, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final DateTime currentDate = date.add(Duration(days: index - 2));
        final bool isSelected = currentDate.day == selectedDate.day &&
            currentDate.month == selectedDate.month &&
            currentDate.year == selectedDate.year;

        return GestureDetector(
          onTap: () async {
            await onDateSelected(currentDate);
          },
          child: _buildDateCard(context, '${currentDate.day}', isSelected),
        );
      }),
    );
  }

  Widget _buildDateCard(BuildContext context, String date, bool isSelected) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final fontSize = settingsProvider.fontSize;

    return AspectRatio(
      aspectRatio: 0.9,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            date,
            style: TextStyle(
              fontSize: fontSize,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  String _vendorNameFor(Expense expense) {
    if (expense.vendorId == null) {
      return tr('uncategorized');
    }
    return vendorsById[expense.vendorId]?.name ?? tr('uncategorized');
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final textColor = settingsProvider.themeMode == ThemeMode.dark
        ? Colors.white
        : Colors.deepPurple;
    final fontSize = settingsProvider.fontSize;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildExpenseAndGreeting(context, fontSize, textColor),
          const SizedBox(height: 16),
          _buildDateScroller(context, fontSize, textColor),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              tr('expenses_for_selected_day'),
              style: TextStyle(
                fontSize: fontSize + 2,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (selectedDayExpenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                tr('no_expenses_for_day'),
                style: TextStyle(fontSize: fontSize - 1, color: textColor.withValues(alpha: 0.8)),
              ),
            )
          else
            ...selectedDayExpenses.map(
              (expense) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text(
                    _vendorNameFor(expense),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize - 1,
                    ),
                  ),
                  subtitle: expense.note == null || expense.note!.trim().isEmpty
                      ? null
                      : Text(expense.note!),
                  trailing: Text(
                    NumberFormat.currency(
                      locale: context.locale.toLanguageTag(),
                      symbol: '₹',
                      decimalDigits: 2,
                    ).format(expense.amount),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize - 1,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAddExpense,
                icon: const Icon(Icons.add),
                label: Text(tr('add_expense')),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String convertMonthIntToNameString(int month, String languageCode) {
    if (languageCode == 'en') {
      switch (month) {
        case 1:
          return 'Jan';
        case 2:
          return 'Feb';
        case 3:
          return 'Mar';
        case 4:
          return 'Apr';
        case 5:
          return 'May';
        case 6:
          return 'June';
        case 7:
          return 'July';
        case 8:
          return 'Aug';
        case 9:
          return 'Sept';
        case 10:
          return 'Oct';
        case 11:
          return 'Nov';
        case 12:
          return 'Dec';
        default:
          return 'Jan';
      }
    } else if (languageCode == 'hi') {
      switch (month) {
        case 1:
          return 'जनवरी';
        case 2:
          return 'फरवरी';
        case 3:
          return 'मार्च';
        case 4:
          return 'अप्रैल';
        case 5:
          return 'मई';
        case 6:
          return 'जून';
        case 7:
          return 'जुलाई';
        case 8:
          return 'अगस्त';
        case 9:
          return 'सितंबर';
        case 10:
          return 'अक्टूबर';
        case 11:
          return 'नवंबर';
        case 12:
          return 'दिसंबर';
        default:
          return 'जनवरी';
      }
    } else {
      return 'Jan';
    }
  }

  Widget _buildExpenseAndGreeting(
      BuildContext context, double fontSize, Color textColor) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: settingsProvider.themeMode == ThemeMode.dark
                      ? const Color.fromARGB(255, 55, 54, 54)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'total_expense_this_month',
                      style: TextStyle(
                        fontSize: fontSize - 2,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).tr(args: [
                      convertMonthIntToNameString(
                          selectedDate.month, context.locale.languageCode)
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      monthTotalLabel,
                      style: TextStyle(
                        fontSize: fontSize + 1,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        handleNavigateToAnalysis();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        tr('view_analysis'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize - 2,
                          color: Colors.deepPurple,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: settingsProvider.themeMode == ThemeMode.dark
                      ? const Color.fromARGB(255, 55, 54, 54)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'greeting',
                      style: TextStyle(
                        fontSize: fontSize + 1,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).tr(args: [user.name]),
                    const SizedBox(height: 8),
                    Text(
                      tr('cta_text'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize - 2,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
