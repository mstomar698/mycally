import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;
  double _fontSize = 16.0;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }
}
