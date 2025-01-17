import 'package:flutter/material.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final String selectedLanguage = settingsProvider.locale.languageCode;
    final double selectedFontSize = settingsProvider.fontSize;
    final ThemeMode selectedThemeMode = settingsProvider.themeMode;

    final backgroundColor =
        selectedThemeMode == ThemeMode.dark ? Colors.black : Colors.white;
    final textColor =
        selectedThemeMode == ThemeMode.dark ? Colors.white : Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}
