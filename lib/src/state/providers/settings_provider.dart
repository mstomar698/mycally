import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;
  double _fontSize = 16.0;

  int? _currentUserId;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;
  int? get currentUserId => _currentUserId;

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

  void setCurrentUserId(int userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  void clearCurrentUserId() {
    _currentUserId = null;
    notifyListeners();
  }
}
