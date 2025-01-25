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
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomePlaceholder(),
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
        // ignore: deprecated_member_use
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

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

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

    return Container(
      color: backgroundColor,
      child: Center(
        child: Text(
          'Home Page',
          style: TextStyle(
            fontSize: fontSize + 2,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
