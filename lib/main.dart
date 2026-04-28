import 'dart:math';

import 'package:educu_project/constant/theme_notifier.dart';
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/firebase_options.dart';
import 'package:educu_project/services/notification_service.dart';
import 'package:educu_project/services/one_signal_service.dart';
import 'package:educu_project/view/splash_screen.dart';
import 'package:educu_project/view/schedule/pomodoro.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize foreground task communication port
  FlutterForegroundTask.initCommunicationPort();

  await PreferenceHandler().init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //push notifikasi dari server
  try {
    setupOneSignal();
  } catch (e) {
    debugPrint('Error setup OneSignal : $e');
  }

  // load dark mode preference
  await ThemeNotifier().loadFromPrefs();

  // init notification service
  await NotificationService().init();
  await NotificationService().requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  /// Global navigator key for routing from notification taps
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  /// Handle data from the foreground service — navigate on notification tap
  void _onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      final action = data['action'] as String?;
      if (action == 'navigate_pomodoro') {
        _navigateToPomodoro();
      }
    }
  }

  /// Navigate to PomodoroScreen using saved session data
  Future<void> _navigateToPomodoro() async {
    final navigator = MyApp.navigatorKey.currentState;
    if (navigator == null) return;

    final subject = await FlutterForegroundTask.getData<String>(key: 'subject');
    final topic = await FlutterForegroundTask.getData<String>(key: 'topic');
    final sessionId =
        await FlutterForegroundTask.getData<String>(key: 'sessionId');
    final startTime =
        await FlutterForegroundTask.getData<String>(key: 'startTime');
    final endTime =
        await FlutterForegroundTask.getData<String>(key: 'endTime');

    navigator.push(
      MaterialPageRoute(
        builder: (_) => PomodoroScreen(
          subject: subject ?? 'Belajar',
          topic: topic ?? '',
          sessionId: (sessionId?.isNotEmpty ?? false) ? sessionId : null,
          startTime: startTime ?? '08:00',
          endTime: endTime ?? '09:00',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeNotifier(),
      builder: (context, themeMode, _) {
        return MaterialApp(
          navigatorKey: MyApp.navigatorKey,
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

          // ── ROUTES ──
          home: const SplashScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == '/pomodoro') {
              // Cold-start from notification: build PomodoroScreen asynchronously
              return MaterialPageRoute(
                builder: (_) => FutureBuilder(
                  future: _loadPomodoroParams(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      final params = snapshot.data as Map<String, String>;
                      return PomodoroScreen(
                        subject: params['subject'] ?? 'Belajar',
                        topic: params['topic'] ?? '',
                        sessionId: (params['sessionId']?.isNotEmpty ?? false)
                            ? params['sessionId']
                            : null,
                        startTime: params['startTime'] ?? '08:00',
                        endTime: params['endTime'] ?? '09:00',
                      );
                    }
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              );
            }
            return null;
          },
        );
      },
    );
  }

  /// Load saved pomodoro session params for cold-start route
  Future<Map<String, String>> _loadPomodoroParams() async {
    final subject =
        await FlutterForegroundTask.getData<String>(key: 'subject') ?? 'Belajar';
    final topic =
        await FlutterForegroundTask.getData<String>(key: 'topic') ?? '';
    final sessionId =
        await FlutterForegroundTask.getData<String>(key: 'sessionId') ?? '';
    final startTime =
        await FlutterForegroundTask.getData<String>(key: 'startTime') ?? '08:00';
    final endTime =
        await FlutterForegroundTask.getData<String>(key: 'endTime') ?? '09:00';
    return {
      'subject': subject,
      'topic': topic,
      'sessionId': sessionId,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
