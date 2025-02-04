// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mycally/src/data/models/user.dart';
import 'package:mycally/src/data/services/database.dart';
import 'package:mycally/src/presentation/screens/analysis/analysis_screen.dart';
import 'package:mycally/src/presentation/screens/profile/profile_screen.dart';
import 'package:mycally/src/presentation/screens/reports/reports_screen.dart';
import 'package:mycally/src/presentation/screens/settings/settings_screen.dart';
import 'package:mycally/src/presentation/widgets/pull_to_refresh_wrapper.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showCalendar = false;
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Future<User?>? _userFuture;
  final String _totalExpance = '₹2,450';

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
    setState(() {
      _selectedDate = DateTime.now();
      _loadUser();
    });
    await _userFuture;
  }

  void _handleDateSelected(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    debugPrint('Selected Date: $_selectedDate');
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
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final backgroundColor = settingsProvider.themeMode == ThemeMode.dark
        ? Colors.black
        : Colors.white;
    final textColor = settingsProvider.themeMode == ThemeMode.dark
        ? Colors.white
        : Colors.deepPurple;
    final fontSize = settingsProvider.fontSize;
    print('Current Index $_currentIndex');
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
                    color: textColor.withOpacity(0.6),
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
                    totalExpance: _totalExpance,
                    calendarFormat: _calendarFormat,
                    onDateSelected: _handleDateSelected,
                    onFormatChangedTrigger: _handleFormatChanged,
                    onShowCalendarChanged: _handleShowCalendarChanged,
                    handleNavigateToAnalysis: _handleNavigateToAnalysis,
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
          unselectedItemColor: textColor.withOpacity(0.6),
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
  final String totalExpance;
  final DateTime selectedDate;
  final CalendarFormat _calendarFormat;
  final Function(DateTime) onDateSelected;
  final Function(bool) onShowCalendarChanged;
  final Function(CalendarFormat) onFormatChangedTrigger;
  final Function() handleNavigateToAnalysis;

  const HomePageContent({
    super.key,
    required this.user,
    required this.totalExpance,
    required this.selectedDate,
    required this.showCalendar,
    required this.onDateSelected,
    required this.onShowCalendarChanged,
    required this.onFormatChangedTrigger,
    required CalendarFormat calendarFormat,
    required this.handleNavigateToAnalysis,
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
          onDaySelected: (selectedDay, focusedDay) {
            onDateSelected(selectedDay);
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
          onTap: () {
            onDateSelected(currentDate);
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

  Widget _buildVendorDetailsModal(
    BuildContext context, {
    required String vendorName,
    required String vendorType,
    required String amountDelivered,
    required double fontSize,
  }) {
    return AlertDialog(
      content: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              vendorName,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Type: $vendorType'),
            const SizedBox(height: 8),
            Text('Amount Delivered: $amountDelivered'),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context, String vendorName,
      String vendorType, String amountDelivered) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final fontSize = settingsProvider.fontSize;
    final textColor = settingsProvider.themeMode == ThemeMode.dark
        ? Colors.white
        : Colors.deepPurple;

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => _buildVendorDetailsModal(
            context,
            vendorName: vendorName,
            vendorType: vendorType,
            amountDelivered: amountDelivered,
            fontSize: fontSize,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$vendorName ($vendorType)',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Switch(
                          value: true,
                          onChanged: (bool value) {
                            debugPrint(
                                'Toggle for $vendorName changed to $value');
                          },
                          activeColor: Colors.deepPurple,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: textColor),
                          onSelected: (value) {
                            if (value == 'hide') {
                              debugPrint('Hide vendor $vendorName');
                            } else if (value == 'details') {
                              debugPrint('Show details for vendor $vendorName');
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'hide',
                              child: Text(tr('hide_vendor')),
                            ),
                            PopupMenuItem(
                              value: 'details',
                              child: Text(tr('vendor_details')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${tr('amount_delivered')}: $amountDelivered',
                style: TextStyle(
                  fontSize: fontSize - 2,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              tr('vendor_list'),
              style: TextStyle(
                fontSize: fontSize + 2,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildVendorCard(context, 'Ram', 'milk', '2 litres'),
          _buildVendorCard(context, 'Shyam', 'grocery', '3 units'),
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
                      totalExpance,
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
