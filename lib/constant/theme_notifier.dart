import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global theme notifier singleton — accessible from anywhere
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;

  ThemeNotifier._internal() : super(ThemeMode.light);

  static const String _key = 'isDarkMode';

  /// Load saved theme preference
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? false;
    value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme(bool isDark) async {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
  }

  bool get isDark => value == ThemeMode.dark;
}
