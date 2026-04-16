import 'package:educu_project/constant/theme_notifier.dart';
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/firebase_options.dart';
import 'package:educu_project/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PreferenceHandler().init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // load dark mode preference
  await ThemeNotifier().loadFromPrefs();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeNotifier(),
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'EduCu',
          themeMode: themeMode,

          // ── LIGHT THEME ──
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4388FF),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF3F3F6),
            cardColor: Colors.white,
            dividerColor: Colors.grey.shade300,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF6554FF),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF4388FF),
              unselectedItemColor: Colors.grey,
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF4388FF);
                }
                return Colors.grey;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF4388FF).withValues(alpha: 0.4);
                }
                return Colors.grey.shade300;
              }),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF6F5FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          // ── DARK THEME ──
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4388FF),
              brightness: Brightness.dark,
              surface: const Color(0xFF1A1A2E),
              onSurface: const Color(0xFFE8E8E8),
            ),
            scaffoldBackgroundColor: const Color(0xFF0F0F23),
            cardColor: const Color(0xFF1A1A2E),
            dividerColor: Colors.white12,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF16213E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1A1A2E),
              selectedItemColor: Color(0xFF4D8CFF),
              unselectedItemColor: Colors.grey,
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF4D8CFF);
                }
                return Colors.grey;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF4D8CFF).withValues(alpha: 0.4);
                }
                return Colors.grey.shade700;
              }),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF252547),
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1A1A2E),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              contentTextStyle: TextStyle(color: Color(0xFFCCCCCC)),
            ),
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: Color(0xFF252547),
              contentTextStyle: TextStyle(color: Colors.white),
            ),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}
