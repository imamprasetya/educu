import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/database/sqflite.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Notification channel IDs
  static const String _channelId = 'educu_study_reminders';
  static const String _channelName = 'Study Reminders';
  static const String _channelDesc = 'Notifications for study schedule reminders';

  static const String _silentChannelId = 'educu_study_silent';
  static const String _silentChannelName = 'Study Reminders (Silent)';
  static const String _silentChannelDesc = 'Silent notifications for study reminders';

  // Notification ID ranges
  static const int _dailySummaryId = 10000;
  static const int _missedYesterdayId = 10001;
  static const int _beforeSessionBase = 20000;
  static const int _startSessionBase = 30000;
  static const int _missedSessionBase = 40000;

  /// Initialize the notification plugin and timezone
  Future<void> init() async {
    if (_initialized) return;

    // Init timezone
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Android init settings
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // For now, just opening the app is sufficient
    // Can be extended to navigate to specific screens
  }

  /// Request notification permissions (Android 13+)
  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Get the appropriate notification details based on sound setting
  NotificationDetails _getNotificationDetails({bool withSound = true}) {
    if (withSound) {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/launcher_icon',
          styleInformation: BigTextStyleInformation(''),
        ),
      );
    } else {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          _silentChannelId,
          _silentChannelName,
          channelDescription: _silentChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          playSound: false,
          enableVibration: false,
          icon: '@mipmap/launcher_icon',
          styleInformation: BigTextStyleInformation(''),
        ),
      );
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Schedule a notification at a specific time
  Future<void> _scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final pref = PreferenceHandler();

    // Check if popup notifications are enabled
    if (!pref.getPopupNotif()) return;

    // Check if the time is in the future
    if (scheduledTime.isBefore(DateTime.now())) return;

    final soundEnabled = pref.getSoundNotif();
    final details = _getNotificationDetails(withSound: soundEnabled);

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  /// Show an immediate notification
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    final pref = PreferenceHandler();
    if (!pref.getPopupNotif()) return;

    final soundEnabled = pref.getSoundNotif();
    final details = _getNotificationDetails(withSound: soundEnabled);

    await _plugin.show(id, title, body, details);
  }

  // ══════════════════════════════════════════════════════════════
  //  MAIN SCHEDULING — called after login, add/edit program, etc.
  // ══════════════════════════════════════════════════════════════

  /// Schedule all notifications based on current sessions
  Future<void> scheduleAllNotifications() async {
    final pref = PreferenceHandler();

    // If popup is disabled, cancel everything and return
    if (!pref.getPopupNotif()) {
      await cancelAll();
      return;
    }

    // Cancel existing then reschedule
    await cancelAll();

    final userIdStr = await PreferenceHandler.getUserId();
    if (userIdStr == null) return;
    int userId = int.parse(userIdStr);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    final reminderMinutes = pref.getReminderMinutes();

    // Format date strings
    String formatDate(DateTime d) =>
        "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    final todayStr = formatDate(today);
    final tomorrowStr = formatDate(tomorrow);
    final yesterdayStr = formatDate(yesterday);

    // Get all programs for user
    final dbPrograms = await DBHelper.getProgramsByUser(userId);

    // Helper to get sessions by date with subject
    Future<List<Map<String, dynamic>>> getSessionsForDate(String dateStr) async {
      List<Map<String, dynamic>> list = [];
      for (var program in dbPrograms) {
        if (program['id'] != null) {
          final pSessions = await DBHelper.getSessions(program['id']);
          for (var s in pSessions) {
            if (s['date'] == dateStr) {
              final sessionData = Map<String, dynamic>.from(s);
              sessionData['subject'] = program['subject'];
              list.add(sessionData);
            }
          }
        }
      }
      return list;
    }

    // ── 1. Get today's sessions ──
    final todaySessions = await getSessionsForDate(todayStr);
    final incompleteTodaySessions =
        todaySessions.where((s) => s['completed'] != 1).toList();

    // ── 2. Get tomorrow's sessions ──
    final tomorrowSessions = await getSessionsForDate(tomorrowStr);

    // ── 3. Get yesterday's missed sessions ──
    final yesterdaySessions = await getSessionsForDate(yesterdayStr);
    final missedYesterday =
        yesterdaySessions.where((s) => s['completed'] != 1).toList();

    // ── Schedule: Daily summary at midnight for tomorrow ──
    if (tomorrowSessions.isNotEmpty) {
      final midnightTomorrow = tomorrow;
      await _scheduleAt(
        id: _dailySummaryId,
        title: "📚 Jadwal Belajar Hari Ini",
        body: "Kamu punya ${tomorrowSessions.length} sesi belajar hari ini. Semangat!",
        scheduledTime: midnightTomorrow,
      );
    }

    // ── Schedule: Missed yesterday notification at midnight ──
    // Only if current time hasn't passed midnight yet today (schedule for next midnight)
    // Actually: if yesterday has missed sessions and it's early in the day, show now or at next check
    if (missedYesterday.isNotEmpty && now.hour < 1) {
      // Show immediately if we just passed midnight
      await showNow(
        id: _missedYesterdayId,
        title: "❌ Session Terlewat Kemarin",
        body: "Kemarin ada ${missedYesterday.length} session yang terlewat. Jangan lupa belajar hari ini!",
      );
    }

    // ── Schedule: Per-session notifications for today ──
    int sessionIndex = 0;
    for (final session in incompleteTodaySessions) {
      final startTimeStr = session['startTime'] as String? ?? '';
      final endTimeStr = session['endTime'] as String? ?? '';
      final subject = session['subject'] as String? ?? 'Belajar';
      final topic = session['topic'] as String? ?? '';

      final startDt = _parseSessionDateTime(todayStr, startTimeStr);
      final endDt = _parseSessionDateTime(todayStr, endTimeStr);

      if (startDt != null) {
        // ── Before session (reminder N minutes before) ──
        final beforeTime = startDt.subtract(Duration(minutes: reminderMinutes));
        await _scheduleAt(
          id: _beforeSessionBase + sessionIndex,
          title: "⏰ $subject dimulai dalam $reminderMinutes menit",
          body: topic.isNotEmpty ? "Materi: $topic" : "Bersiaplah untuk belajar!",
          scheduledTime: beforeTime,
        );

        // ── At session start ──
        await _scheduleAt(
          id: _startSessionBase + sessionIndex,
          title: "🎯 Waktunya Belajar!",
          body: "$subject${topic.isNotEmpty ? ' - $topic' : ''}",
          scheduledTime: startDt,
        );
      }

      if (endDt != null) {
        // ── Missed notification at end time ──
        await _scheduleAt(
          id: _missedSessionBase + sessionIndex,
          title: "⚠️ Session Terlewat",
          body: "$subject${topic.isNotEmpty ? ' - $topic' : ''} belum diselesaikan!",
          scheduledTime: endDt,
        );
      }

      sessionIndex++;
    }

    // ── Also schedule for tomorrow's sessions ──
    int tomorrowIndex = 0;
    final incompleteTomorrow =
        tomorrowSessions.where((s) => s['completed'] != 1).toList();

    for (final session in incompleteTomorrow) {
      final startTimeStr = session['startTime'] as String? ?? '';
      final endTimeStr = session['endTime'] as String? ?? '';
      final subject = session['subject'] as String? ?? 'Belajar';
      final topic = session['topic'] as String? ?? '';

      final startDt = _parseSessionDateTime(tomorrowStr, startTimeStr);
      final endDt = _parseSessionDateTime(tomorrowStr, endTimeStr);

      // Use offset indices to avoid collision with today's IDs
      final offset = 5000 + tomorrowIndex;

      if (startDt != null) {
        final beforeTime = startDt.subtract(Duration(minutes: reminderMinutes));
        await _scheduleAt(
          id: _beforeSessionBase + offset,
          title: "⏰ $subject dimulai dalam $reminderMinutes menit",
          body: topic.isNotEmpty ? "Materi: $topic" : "Bersiaplah untuk belajar!",
          scheduledTime: beforeTime,
        );

        await _scheduleAt(
          id: _startSessionBase + offset,
          title: "🎯 Waktunya Belajar!",
          body: "$subject${topic.isNotEmpty ? ' - $topic' : ''}",
          scheduledTime: startDt,
        );
      }

      if (endDt != null) {
        await _scheduleAt(
          id: _missedSessionBase + offset,
          title: "⚠️ Session Terlewat",
          body: "$subject${topic.isNotEmpty ? ' - $topic' : ''} belum diselesaikan!",
          scheduledTime: endDt,
        );
      }

      tomorrowIndex++;
    }

    // ── Schedule midnight check for tomorrow (to load next day's sessions) ──
    // This triggers a "daily summary" notification
    final midnightCheck = tomorrow.add(const Duration(seconds: 5));
    if (incompleteTomorrow.isNotEmpty) {
      await _scheduleAt(
        id: _dailySummaryId + 1,
        title: "📚 Jadwal Belajar Hari Ini",
        body: "Kamu punya ${incompleteTomorrow.length} sesi belajar hari ini!",
        scheduledTime: midnightCheck,
      );
    }

    // Also check if today has missed sessions → schedule midnight notification
    if (incompleteTodaySessions.isNotEmpty) {
      // At midnight tonight, check if any sessions from today were not completed
      final midnightTonight = tomorrow;
      await _scheduleAt(
        id: _missedYesterdayId + 1,
        title: "❌ Session Terlewat",
        body: "Hari ini ada ${incompleteTodaySessions.length} session yang belum diselesaikan.",
        scheduledTime: midnightTonight.add(const Duration(minutes: 1)),
      );
    }
  }

  /// Parse a session date + time string into a DateTime
  DateTime? _parseSessionDateTime(String dateStr, String timeStr) {
    try {
      final dateParts = dateStr.split('-');
      if (dateParts.length < 3) return null;

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      // Handle various time formats
      final lower = timeStr.toLowerCase().trim();

      if (lower.isEmpty) return null;

      int hour;
      int minute;

      if (lower.contains('am') || lower.contains('pm')) {
        // "h:mm AM/PM" format
        final isPM = lower.contains('pm');
        final isAM = lower.contains('am');
        final cleaned = lower.replaceAll(RegExp(r'[ap]m'), '').trim();
        final parts = cleaned.split(':');
        hour = int.parse(parts[0].trim());
        minute = int.parse(parts[1].trim());
        if (isPM && hour != 12) hour += 12;
        if (isAM && hour == 12) hour = 0;
      } else {
        // "HH:mm" 24h format
        final parts = lower.split(':');
        hour = int.parse(parts[0].trim());
        minute = int.parse(parts[1].trim());
      }

      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      return null;
    }
  }
}
