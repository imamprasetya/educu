import 'package:flutter/material.dart';

class AppColor {
  static const Color navy = Color(0xFF000033);
  static const Color biru = Color(0xFFCDEDFF);
  static const Color biru1 = Color.fromARGB(255, 238, 249, 255);
  static const Color logo = Color(0xFF2F4A6B);
  static const Color box = Color(0xFFEFE9FC);
  static const Color box1 = Color(0xFFF6F5FF);

  //Gradient
  static const Color gradien1 = Color(0xFF6554FF);
  static const Color gradien2 = Color(0xFF4388FF);

  //darkmode
  static const Color gelap = Color(0xFF000031);
  static const Color black = Color(0xFF000020);
  static const Color white = Color(0xFFE0E0E0);

  // ── Dark mode variants ──
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color darkCard = Color(0xFF252547);
  static const Color darkInput = Color(0xFF252547);

  // ── Theme-aware helpers ──

  /// Card / container background
  static Color cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : Colors.white;
  }

  /// Page / scaffold background
  static Color scaffoldColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  /// Text form field fill color
  static Color inputFill(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkInput
        : box1;
  }

  /// Search box background
  static Color searchBox(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkInput
        : box;
  }

  /// Primary text color (high emphasis)
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE8E8E8)
        : Colors.black87;
  }

  /// Secondary text color (medium emphasis)
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFAAAAAA)
        : Colors.black54;
  }

  /// Hint / subtle text color
  static Color textHint(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF888888)
        : Colors.grey;
  }

  /// Border / divider color
  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
  }

  /// Shadow color for cards
  static Color shadowColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black38
        : Colors.black12;
  }

  /// Icon color for settings / generic icons
  static Color iconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFAAAAAA)
        : Colors.grey;
  }

  /// Whether we are currently in dark mode
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
