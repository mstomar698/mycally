// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mycally/src/presentation/screens/analysis/analysis_screen.dart';
import 'package:mycally/src/presentation/screens/profile/profile_screen.dart';
import 'package:mycally/src/presentation/screens/reports/reports_screen.dart';
import 'package:mycally/src/presentation/screens/settings/settings_screen.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _currentDate = DateTime.now();
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomePageContent(),
    AnalysisScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

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

    return Scaffold(
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
      body: _screens[_currentIndex],
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
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  Widget _buildDateScroller(
      BuildContext context, double fontSize, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildDateCard(context, '15', false)),
                Expanded(child: _buildDateCard(context, '16', false)),
                Expanded(child: _buildDateCard(context, '17', true)),
                Expanded(child: _buildDateCard(context, '18', false)),
                Expanded(child: _buildDateCard(context, '19', false)),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    debugPrint('View All Calendar pressed');
                  },
                  child: Text(tr('view_all'),
                      style: TextStyle(
                          fontSize: 12, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(BuildContext context, String date, bool isSelected) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final fontSize = settingsProvider.fontSize;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        date,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          color: isSelected ? Colors.white : Colors.black,
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

    return Card(
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
                    Switch(
                      value: true, 
                      onChanged: (bool value) {
                        debugPrint('Toggle for $vendorName changed to $value');
                      },
                      activeColor: Colors.deepPurple,
                    ),
                    PopupMenuButton<String>(
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
                      tr('total_expense_this_month'),
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹2,450',
                      style: TextStyle(
                        fontSize: fontSize + 4,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      tr('greeting', args: ['Ram']),
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr('cta_text'),
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                      ),
                      maxLines: 1,
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
