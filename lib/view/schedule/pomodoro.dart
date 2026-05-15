import 'dart:async';
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/services/notification_service.dart';
import 'package:flutter/material.dart';
import '../../constant/app_color.dart';

class PomodoroScreen extends StatefulWidget {
  final String subject;
  final String topic;
  final String? sessionId;
  final String startTime;
  final String endTime;

  const PomodoroScreen({
    super.key,
    required this.subject,
    required this.topic,
    this.sessionId,
    this.startTime = "08:00",
    this.endTime = "09:00",
  });

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Pomodoro constants
  static const int studyDuration = 25 * 60;
  static const int shortBreakDuration = 5 * 60;
  static const int longBreakDuration = 20 * 60;
  static const int cyclesBeforeLongBreak = 4;

  // Timer logic
  Timer? _timer;

  // UI state
  int phaseTimeLeft = 0;
  int phaseTotalTime = 0;
  int totalElapsed = 0;
  int totalDurationSeconds = 3600;
  int currentCycle = 1;
  bool isBreak = false;
  bool isLongBreak = false;
  bool isPaused = true;
  bool isAllCompleted = false;
  bool hasStarted = false;

  @override
  void initState() {
    super.initState();
    totalDurationSeconds = _calcTotalDuration();
    
    // Setup initial phase
    _setupPhase(study: true);
    
    // Save params for recovery
    PreferenceHandler().savePomodoroParams(
      subject: widget.subject,
      topic: widget.topic,
      sessionId: widget.sessionId,
      startTime: widget.startTime,
      endTime: widget.endTime,
    );
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
        // No more schedule time, but we can still have a break? 
        // Usually, if schedule ends, we end.
        isAllCompleted = true;
        isPaused = true;
        phaseTimeLeft = 0;
        return;
      }
      phaseTimeLeft = phaseTotalTime;
    }
  }

  void _tick() {
    if (isPaused || isAllCompleted) return;

    setState(() {
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
          _stopTimer();
          _showCompletedDialog();
          return;
        }
      } else {
        // Phase ended
        _onPhaseEnd();
      }
    });
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
        NotificationService().showPomodoroStudy(subject: widget.subject);
      }
    } else {
      // Study finished → check remaining time
      int remaining = totalDurationSeconds - totalElapsed;
      if (remaining <= 0) {
        isAllCompleted = true;
        isPaused = true;
        phaseTimeLeft = 0;
        _stopTimer();
        _showCompletedDialog();
        return;
      }

      // Start break
      _setupPhase(study: false);
      NotificationService().showPomodoroBreak(
        subject: widget.subject,
        isLongBreak: isLongBreak,
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _tick());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Calculate total duration from startTime - endTime
  int _calcTotalDuration() {
    try {
      final start = _parseTime(widget.startTime);
      final end = _parseTime(widget.endTime);
      if (start == null || end == null) return 60 * 60;
      int diff = end.difference(start).inSeconds;
      return diff > 0 ? diff : 60 * 60;
    } catch (_) {
      return 60 * 60;
    }
  }

  DateTime? _parseTime(String time) {
    try {
      final cleaned = time.trim();
      if (cleaned.contains(':') && !cleaned.contains(' ')) {
        final parts = cleaned.split(':');
        return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      }
      final lower = cleaned.toLowerCase();
      final isPM = lower.contains('pm');
      final isAM = lower.contains('am');
      final stripped = lower.replaceAll(RegExp(r'[ap]m'), '').trim();
      final parts = stripped.split(':');
      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].trim());
      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;
      return DateTime(2000, 1, 1, hour, minute);
    } catch (_) {
      return null;
    }
  }

  // FORMAT TIME
  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int sec = seconds % 60;

    if (hours > 0) {
      return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
    }
    return "${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  String get phaseLabel {
    if (isAllCompleted) return "Selesai!";
    if (isBreak && isLongBreak) return "Istirahat Panjang";
    if (isBreak) return "Istirahat";
    return "Belajar";
  }

  Color get phaseColor {
    if (isAllCompleted) return Colors.green;
    if (isBreak) return const Color(0xFF43A047);
    return AppColor.gradien2;
  }

  List<Color> get phaseGradient {
    if (isAllCompleted) {
      return [Colors.green.shade400, Colors.green.shade700];
    }
    if (isBreak && isLongBreak) {
      return [const Color(0xFF66BB6A), const Color(0xFF2E7D32)];
    }
    if (isBreak) {
      return [const Color(0xFF81C784), const Color(0xFF388E3C)];
    }
    return [AppColor.gradien1, AppColor.gradien2];
  }

  IconData get phaseIcon {
    if (isBreak && isLongBreak) return Icons.local_cafe;
    if (isBreak) return Icons.self_improvement;
    return Icons.menu_book;
  }

  // START / RESUME
  void _onStart() {
    setState(() {
      hasStarted = true;
      isPaused = false;
    });
    _startTimer();
  }

  // PAUSE
  void _onPause() {
    setState(() {
      isPaused = true;
    });
    _stopTimer();
  }

  // TOGGLE
  void toggleTimer() {
    if (isPaused) {
      _onStart();
    } else {
      _onPause();
    }
  }

  // RESET
  void resetTimer() {
    final wasRunning = !isPaused;
    if (wasRunning) _onPause();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.refresh,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Reset Timer?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColor.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "Semua progres belajar pada sesi ini akan direset dari awal. Apakah Anda yakin?",
            style: TextStyle(
              color: AppColor.textSecondary(context),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (wasRunning) _onStart();
              },
              child: Text(
                "Batal",
                style: TextStyle(color: AppColor.textSecondary(context)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _stopTimer();
                setState(() {
                  totalElapsed = 0;
                  currentCycle = 1;
                  isPaused = true;
                  isAllCompleted = false;
                  hasStarted = false;
                  isBreak = false;
                  isLongBreak = false;
                  _setupPhase(study: true);
                });
              },
              child: const Text(
                "Ya, Reset",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // SELESAI - mark session as completed
  Future<void> _markComplete() async {
    if (widget.sessionId != null) {
      await FirebaseService.markSessionCompleted(widget.sessionId!);
    }

    NotificationService().scheduleAllNotifications();

    _stopTimer();

    setState(() {
      isPaused = true;
      isAllCompleted = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sesi selesai! Kerja bagus! 🎉"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  // HANDLE SELESAI BUTTON
  void _handleFinish() {
    if (totalElapsed < totalDurationSeconds && !isAllCompleted) {
      _showEarlyFinishDialog();
    } else {
      _markComplete();
    }
  }

  // EARLY FINISH DIALOG
  void _showEarlyFinishDialog() {
    final wasRunning = !isPaused;
    if (wasRunning) _onPause();

    final remaining = totalDurationSeconds - totalElapsed;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Icon(
          Icons.timer_off_outlined,
          size: 50,
          color: Colors.orange.shade400,
        ),
        content: Text(
          "Waktu belajar masih tersisa ${formatTime(remaining)}.\nApakah Anda yakin ingin menyelesaikan sesi ini sekarang?",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColor.textPrimary(context)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (wasRunning) _onStart();
            },
            child: Text(
              "Lanjutkan",
              style: TextStyle(color: AppColor.textHint(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.gradien1),
            onPressed: () {
              Navigator.pop(context);
              _markComplete();
            },
            child: const Text(
              "Selesai Sekarang",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Icon(Icons.celebration, size: 50, color: Colors.orange),
        content: Text(
          "Waktu belajar telah selesai!\nApakah anda ingin menandai session ini sebagai selesai?",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColor.textPrimary(context)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Nanti"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context);
              _markComplete();
            },
            child: const Text(
              "Selesai ✓",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  // Dialog konfirmasi keluar
  Future<bool> _showExitConfirmDialog() async {
    final wasRunning = !isPaused;
    if (wasRunning) _onPause();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Keluar?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColor.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "Timer akan dihentikan dan progres sesi ini tidak akan disimpan. Apakah Anda yakin ingin keluar?",
            style: TextStyle(
              color: AppColor.textSecondary(context),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
                if (wasRunning) _onStart();
              },
              child: Text(
                "Batal",
                style: TextStyle(color: AppColor.textSecondary(context)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Ya, Keluar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result != true && wasRunning) {
      // Dialog dismissed without choosing, resume timer
    }

    return result ?? false;
  }

  double get phaseProgress {
    if (phaseTotalTime == 0) return 0;
    return 1 - (phaseTimeLeft / phaseTotalTime);
  }

  double get totalProgress {
    if (totalDurationSeconds == 0) return 0;
    return totalElapsed / totalDurationSeconds;
  }

  int get totalRemaining => totalDurationSeconds - totalElapsed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Jika belum mulai, langsung keluar tanpa dialog
        if (!hasStarted) {
          Navigator.pop(context);
          return;
        }
        final shouldExit = await _showExitConfirmDialog();
        if (shouldExit && mounted) {
          _stopTimer();
          Navigator.pop(context);
        }
      },
      child: Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColor.isDark(context)
                  ? [AppColor.darkSurface, AppColor.darkCard]
                  : phaseGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async {
                if (!hasStarted) {
                  Navigator.pop(context);
                  return;
                }
                final shouldExit = await _showExitConfirmDialog();
                if (shouldExit && mounted) {
                  _stopTimer();
                  Navigator.pop(context);
                }
              },
            ),
            title: Text(
              isBreak ? "Istirahat" : "Timer Belajar",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // SUBJECT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.cardColor(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowColor(context),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subject,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Topik : ${widget.topic}",
                    style: TextStyle(color: AppColor.textSecondary(context)),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.startTime} - ${widget.endTime}",
                        style: const TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.timer, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "Total: ${formatTime(totalDurationSeconds)}",
                        style: const TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // PHASE STATUS + CYCLE INDICATOR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: phaseGradient),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(phaseIcon, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    phaseLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // cycle dots
                  ...List.generate(cyclesBeforeLongBreak, (i) {
                    final completed = i < currentCycle - 1 ||
                        (i == currentCycle - 1 && isBreak);
                    final isCurrent = i == currentCycle - 1 && !isBreak;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isCurrent ? 14 : 10,
                      height: isCurrent ? 14 : 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completed
                            ? Colors.white
                            : isCurrent
                                ? Colors.white.withOpacity(0.8)
                                : Colors.white.withOpacity(0.3),
                        border: isCurrent
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // CIRCULAR TIMER
            SizedBox(
              height: 220,
              width: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 220,
                    width: 220,
                    child: CircularProgressIndicator(
                      value: phaseProgress,
                      strokeWidth: 10,
                      backgroundColor: AppColor.isDark(context)
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(
                        isAllCompleted ? Colors.green : phaseColor,
                      ),
                    ),
                  ),
                  Container(
                    height: 190,
                    width: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: phaseGradient),
                      boxShadow: [
                        BoxShadow(
                          color: phaseColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: isAllCompleted
                          ? const Icon(
                              Icons.check,
                              size: 60,
                              color: Colors.white,
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formatTime(phaseTimeLeft),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  phaseLabel,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TOTAL REMAINING
            if (!isAllCompleted)
              Text(
                "Sisa jadwal: ${formatTime(totalRemaining > 0 ? totalRemaining : 0)}",
                style: TextStyle(
                  color: AppColor.textHint(context),
                  fontSize: 13,
                ),
              ),

            const SizedBox(height: 8),

            // TOTAL PROGRESS BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Progress Jadwal",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColor.textHint(context),
                        ),
                      ),
                      Text(
                        "${(totalProgress * 100).toInt()}%",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: phaseColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: totalProgress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: AppColor.isDark(context)
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(phaseColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // CONTROL BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // START / PAUSE TOGGLE
                SizedBox(
                  width: 140,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPaused ? Colors.green : Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: isAllCompleted ? null : toggleTimer,
                    icon: Icon(
                      isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                    ),
                    label: Text(
                      isPaused ? "Mulai" : "Jeda",
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // RESET
                SizedBox(
                  width: 140,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: isAllCompleted ? null : resetTimer,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      "Reset",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // SELESAI BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isAllCompleted ? Colors.grey : AppColor.gradien1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: isAllCompleted ? null : _handleFinish,
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: Text(
                  isAllCompleted ? "Sudah Selesai" : "Selesai",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
