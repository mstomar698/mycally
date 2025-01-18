import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mycally/src/config/constants.dart';

class LocalizationService {
  static const String _languageCodeKey = 'languageCode';
  static const String _themeModeKey = 'themeMode';
  static const String _fontSizeKey = 'fontSize';

  static Future<void> loadPreferences(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Obtain the SettingsProvider instance
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    // 1. Load language
    String? languageCode = prefs.getString(_languageCodeKey);
    if (languageCode != null) {
      // Update Easy Localization
      if (context.mounted) {
        context.setLocale(Locale(languageCode));
      }
      // Also update SettingsProvider
      settingsProvider.setLocale(Locale(languageCode));
    }

    // 2. Load theme
    String? theme = prefs.getString(_themeModeKey);
    if (theme != null) {
      // Convert string to ThemeMode
      final themeMode = (theme == 'dark') ? ThemeMode.dark : ThemeMode.light;
      settingsProvider.setThemeMode(themeMode);
    }

    // 3. Load font size
    double? fontSize = prefs.getDouble(_fontSizeKey);
    if (fontSize != null) {
      settingsProvider.setFontSize(fontSize);
    }
  }

  static Future<void> setLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
  }

  static Future<void> setThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode);
  }

  static Future<void> setFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, fontSize);
  }

  static Future<void> setLanguageSelected(bool isSet) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLanguageSetKey, isSet);
  }

  static Future<bool> isLanguageSelected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLanguageSetKey) ?? false;
  }
}
