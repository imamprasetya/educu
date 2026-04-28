import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Top-level callback – must be top-level or static
@pragma('vm:entry-point')
void startPomodoroCallback() {
  FlutterForegroundTask.setTaskHandler(PomodoroTaskHandler());
}

/// Runs in the foreground-service isolate.
/// Receives config from the UI, counts down every second,
/// sends state back to the UI, and updates the notification.
class PomodoroTaskHandler extends TaskHandler {
  // Pomodoro constants
  static const int studyDuration = 25 * 60;
  static const int shortBreakDuration = 5 * 60;
  static const int longBreakDuration = 20 * 60;
  static const int cyclesBeforeLongBreak = 4;

  // State
  int totalDurationSeconds = 3600;
  int totalElapsed = 0;
  int phaseTimeLeft = 0;
  int phaseTotalTime = 0;
  int currentCycle = 1;
  bool isBreak = false;
  bool isLongBreak = false;
  bool isPaused = true;
  bool isAllCompleted = false;
  String subject = '';

  Timer? _ticker;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Read saved config
    final totalDur = await FlutterForegroundTask.getData<int>(
      key: 'totalDurationSeconds',
    );
    final subj = await FlutterForegroundTask.getData<String>(key: 'subject');
    final elapsed = await FlutterForegroundTask.getData<int>(
      key: 'totalElapsed',
    );
    final cycle = await FlutterForegroundTask.getData<int>(key: 'currentCycle');
    final phaseLeft = await FlutterForegroundTask.getData<int>(
      key: 'phaseTimeLeft',
    );
    final phaseTotal = await FlutterForegroundTask.getData<int>(
      key: 'phaseTotalTime',
    );
    final brk = await FlutterForegroundTask.getData<bool>(key: 'isBreak');
    final longBrk = await FlutterForegroundTask.getData<bool>(
      key: 'isLongBreak',
    );
    final paused = await FlutterForegroundTask.getData<bool>(key: 'isPaused');

    totalDurationSeconds = totalDur ?? 3600;
    subject = subj ?? 'Belajar';
    totalElapsed = elapsed ?? 0;
    currentCycle = cycle ?? 1;
    isBreak = brk ?? false;
    isLongBreak = longBrk ?? false;
    isPaused = paused ?? false;

    if (phaseLeft != null && phaseTotal != null) {
      phaseTimeLeft = phaseLeft;
      phaseTotalTime = phaseTotal;
    } else {
      _setupPhase(study: true);
    }

    // Start 1-second ticker
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());

    _sendState();
    _updateNotification();
  }

  void _tick() {
    if (isPaused || isAllCompleted) return;

    if (phaseTimeLeft > 0) {
      phaseTimeLeft--;
      if (!isBreak) {
        totalElapsed++;
      }

      // Check if total schedule time is exhausted during study
      if (!isBreak && totalElapsed >= totalDurationSeconds) {
        isAllCompleted = true;
        isPaused = true;
        phaseTimeLeft = 0;
        _sendState();
        _updateNotification();
        _saveState();
        return;
      }

      _sendState();

      // Update notification every 5 seconds to save battery
      if (phaseTimeLeft % 5 == 0 || phaseTimeLeft <= 10) {
        _updateNotification();
      }
    } else {
      // Phase ended
      _onPhaseEnd();
    }
  }

  void _onPhaseEnd() {
    if (isBreak) {
      // Break finished → start study
      if (isLongBreak) {
        currentCycle = 1;
      } else {
        currentCycle++;
      }
      _setupPhase(study: true);

      if (!isAllCompleted) {
        // Auto-start next study phase
        isPaused = false;
      }
    } else {
      // Study finished → check remaining time
      int remaining = totalDurationSeconds - totalElapsed;
      if (remaining <= 0) {
        isAllCompleted = true;
        isPaused = true;
        phaseTimeLeft = 0;
        _sendState();
        _updateNotification();
        _saveState();
        return;
      }

      // Start break
      _setupPhase(study: false);
      // Auto-start break
      isPaused = false;
    }

    _sendState();
    _updateNotification();
    _saveState();
  }

  void _setupPhase({required bool study}) {
    if (study) {
      isBreak = false;
      isLongBreak = false;
      int remaining = totalDurationSeconds - totalElapsed;
      if (remaining <= 0) {
        isAllCompleted = true;
        isPaused = true;
        phaseTimeLeft = 0;
        return;
      }
      phaseTotalTime = remaining < studyDuration ? remaining : studyDuration;
      phaseTimeLeft = phaseTotalTime;
    } else {
      isBreak = true;
      if (currentCycle >= cyclesBeforeLongBreak) {
        isLongBreak = true;
        phaseTotalTime = longBreakDuration;
      } else {
        isLongBreak = false;
        phaseTotalTime = shortBreakDuration;
      }
      int remaining = totalDurationSeconds - totalElapsed;
      if (remaining <= 0) {
        isAllCompleted = true;
        isPaused = true;
        phaseTimeLeft = 0;
        return;
      }
      phaseTimeLeft = phaseTotalTime;
    }
  }

  String _formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    if (h > 0) {
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  String get _phaseLabel {
    if (isAllCompleted) return "Selesai!";
    if (isBreak && isLongBreak) return "Istirahat Panjang";
    if (isBreak) return "Istirahat";
    return "Belajar";
  }

  void _sendState() {
    FlutterForegroundTask.sendDataToMain({
      'phaseTimeLeft': phaseTimeLeft,
      'phaseTotalTime': phaseTotalTime,
      'totalElapsed': totalElapsed,
      'totalDurationSeconds': totalDurationSeconds,
      'currentCycle': currentCycle,
      'isBreak': isBreak,
      'isLongBreak': isLongBreak,
      'isPaused': isPaused,
      'isAllCompleted': isAllCompleted,
      'subject': subject,
    });
  }

  void _updateNotification() {
    String title;
    String text;

    if (isAllCompleted) {
      title = "✅ $subject — Selesai!";
      text = "Semua sesi telah selesai. Kerja bagus!";
    } else if (isPaused) {
      title = "⏸ $subject — $_phaseLabel (Dijeda)";
      text = "Sisa: ${_formatTime(phaseTimeLeft)} | Siklus $currentCycle/4";
    } else {
      title = "${isBreak ? '😌' : '📖'} $subject — $_phaseLabel";
      text =
          "${_formatTime(phaseTimeLeft)} | Siklus $currentCycle/4 | Jadwal: ${_formatTime((totalDurationSeconds - totalElapsed).clamp(0, totalDurationSeconds))}";
    }

    FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: text,
    );
  }

  Future<void> _saveState() async {
    await FlutterForegroundTask.saveData(
      key: 'totalElapsed',
      value: totalElapsed,
    );
    await FlutterForegroundTask.saveData(
      key: 'currentCycle',
      value: currentCycle,
    );
    await FlutterForegroundTask.saveData(
      key: 'phaseTimeLeft',
      value: phaseTimeLeft,
    );
    await FlutterForegroundTask.saveData(
      key: 'phaseTotalTime',
      value: phaseTotalTime,
    );
    await FlutterForegroundTask.saveData(key: 'isBreak', value: isBreak);
    await FlutterForegroundTask.saveData(
      key: 'isLongBreak',
      value: isLongBreak,
    );
    await FlutterForegroundTask.saveData(key: 'isPaused', value: isPaused);
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // We use our own Timer, so nothing needed here
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map<String, dynamic>) {
      final action = data['action'] as String?;
      if (action == 'pause') {
        isPaused = true;
        _sendState();
        _updateNotification();
        _saveState();
      } else if (action == 'resume') {
        if (!isAllCompleted) {
          isPaused = false;
          _sendState();
          _updateNotification();
        }
      } else if (action == 'reset') {
        totalElapsed = 0;
        currentCycle = 1;
        isPaused = true;
        isAllCompleted = false;
        _setupPhase(study: true);
        _sendState();
        _updateNotification();
        _saveState();
      } else if (action == 'sync') {
        _sendState();
      }
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'btn_pause_resume') {
      if (isPaused) {
        if (!isAllCompleted) {
          isPaused = false;
        }
      } else {
        isPaused = true;
      }
      _sendState();
      _updateNotification();
      _saveState();
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/pomodoro');
    // Send navigation signal to main isolate (for warm start)
    FlutterForegroundTask.sendDataToMain({
      'action': 'navigate_pomodoro',
    });
  }

  @override
  void onNotificationDismissed() {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _ticker?.cancel();
    _ticker = null;
    await _saveState();
  }
}
