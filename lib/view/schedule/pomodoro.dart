import 'dart:async';
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

class _PomodoroScreenState extends State<PomodoroScreen>
    with SingleTickerProviderStateMixin {
  // Pomodoro constants
  static const int studyDuration = 25 * 60; // 25 menit
  static const int shortBreakDuration = 5 * 60; // 5 menit
  static const int longBreakDuration = 20 * 60; // 20 menit
  static const int cyclesBeforeLongBreak = 4;

  // State
  late int totalDurationSeconds; // total durasi dari jadwal
  int totalElapsed = 0; // total detik yang sudah berlalu
  int phaseTimeLeft = 0; // sisa waktu fase saat ini
  int phaseTotalTime = 0; // total waktu fase saat ini
  int currentCycle = 1; // siklus ke berapa (1-4)
  bool isBreak = false; // sedang istirahat?
  bool isLongBreak = false; // istirahat panjang?
  bool isRunning = false;
  bool isAllCompleted = false; // semua waktu jadwal habis
  bool hasStarted = false; // sudah pernah klik mulai

  Timer? timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    totalDurationSeconds = _calcTotalDuration();
    _setupPhase(study: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  /// Hitung total durasi jadwal dalam detik dari startTime - endTime
  int _calcTotalDuration() {
    try {
      final start = _parseTime(widget.startTime);
      final end = _parseTime(widget.endTime);
      if (start == null || end == null) return 60 * 60; // fallback 1 jam
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

  /// Setup fase baru (belajar atau istirahat)
  void _setupPhase({required bool study}) {
    if (study) {
      isBreak = false;
      isLongBreak = false;
      // Cek sisa waktu jadwal
      int remaining = totalDurationSeconds - totalElapsed;
      if (remaining <= 0) {
        _allDone();
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
      // Istirahat tidak mengurangi durasi jadwal, tapi cek dulu
      int remaining = totalDurationSeconds - totalElapsed;
      if (remaining <= 0) {
        _allDone();
        return;
      }
      phaseTimeLeft = phaseTotalTime;
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
    if (isBreak) return const Color(0xFF43A047); // hijau
    return AppColor.gradien2; // biru/ungu
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

  // START TIMER
  void startTimer() {
    if (isRunning || isAllCompleted) return;

    hasStarted = true;
    _pulseController.repeat(reverse: true);

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (phaseTimeLeft > 0) {
        setState(() {
          phaseTimeLeft--;
          if (!isBreak) {
            totalElapsed++;
          }
        });

        // Cek apakah total durasi jadwal sudah habis (hanya saat belajar)
        if (!isBreak && totalElapsed >= totalDurationSeconds) {
          t.cancel();
          _pulseController.stop();
          _pulseController.reset();
          setState(() {
            isRunning = false;
            phaseTimeLeft = 0;
          });
          _allDone();
          return;
        }
      } else {
        t.cancel();
        _pulseController.stop();
        _pulseController.reset();
        setState(() {
          isRunning = false;
        });
        _onPhaseEnd();
      }
    });

    setState(() {
      isRunning = true;
    });
  }

  /// Saat sebuah fase berakhir
  void _onPhaseEnd() {
    if (isBreak) {
      // Istirahat selesai → mulai belajar
      if (isLongBreak) {
        currentCycle = 1; // reset siklus setelah long break
      } else {
        currentCycle++;
      }

      // Kirim notifikasi mulai belajar
      NotificationService().showPomodoroStudy(subject: widget.subject);

      setState(() {
        _setupPhase(study: true);
      });

      if (!isAllCompleted) {
        _showPhaseDialog(
          icon: Icons.menu_book,
          color: AppColor.gradien2,
          title: "Waktunya Belajar! 📖",
          message: "Istirahat selesai. Ayo lanjutkan belajar!\nSiklus ke-$currentCycle",
          buttonText: "Mulai Belajar",
        );
      }
    } else {
      // Belajar selesai → mulai istirahat
      // Cek apakah masih ada sisa waktu
      int remaining = totalDurationSeconds - totalElapsed;
      if (remaining <= 0) {
        _allDone();
        return;
      }

      final willBeLongBreak = currentCycle >= cyclesBeforeLongBreak;

      // Kirim notifikasi istirahat
      NotificationService().showPomodoroBreak(
        subject: widget.subject,
        isLongBreak: willBeLongBreak,
      );

      setState(() {
        _setupPhase(study: false);
      });

      _showPhaseDialog(
        icon: willBeLongBreak ? Icons.local_cafe : Icons.self_improvement,
        color: willBeLongBreak ? const Color(0xFF2E7D32) : const Color(0xFF43A047),
        title: willBeLongBreak
            ? "Istirahat Panjang! ☕"
            : "Saatnya Istirahat! 😌",
        message: willBeLongBreak
            ? "Kamu sudah menyelesaikan 4 siklus!\nIstirahat 20 menit."
            : "Siklus ke-$currentCycle selesai.\nIstirahat 5 menit.",
        buttonText: "OK",
      );
    }
  }

  void _showPhaseDialog({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String buttonText,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Icon(icon, size: 50, color: color),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColor.textPrimary(context),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.textSecondary(context)),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              startTimer(); // auto start fase berikutnya
            },
            child: Text(
              buttonText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Semua waktu jadwal habis
  void _allDone() {
    setState(() {
      isAllCompleted = true;
      isRunning = false;
      phaseTimeLeft = 0;
    });
    _showCompletedDialog();
  }

  // PAUSE TIMER
  void pauseTimer() {
    timer?.cancel();
    _pulseController.stop();
    setState(() {
      isRunning = false;
    });
  }

  // RESET TIMER
  void resetTimer() {
    timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      totalElapsed = 0;
      currentCycle = 1;
      isRunning = false;
      isAllCompleted = false;
      hasStarted = false;
      _setupPhase(study: true);
    });
  }

  // TOGGLE START/PAUSE
  void toggleTimer() {
    if (isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  // SELESAI - mark session as completed
  Future<void> _markComplete() async {
    if (widget.sessionId != null) {
      await FirebaseService.markSessionCompleted(widget.sessionId!);
    }

    // Reschedule notifications (cancel missed notification for this session)
    NotificationService().scheduleAllNotifications();

    timer?.cancel();

    setState(() {
      isRunning = false;
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

  // HANDLE SELESAI BUTTON - show dialog if timer not finished
  void _handleFinish() {
    if (totalElapsed < totalDurationSeconds && !isAllCompleted) {
      _showEarlyFinishDialog();
    } else {
      _markComplete();
    }
  }

  // EARLY FINISH CONFIRMATION DIALOG
  void _showEarlyFinishDialog() {
    // Pause timer while dialog is shown
    final wasRunning = isRunning;
    if (wasRunning) pauseTimer();

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
              if (wasRunning) startTimer();
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
    timer?.cancel();
    _pulseController.dispose();
    super.dispose();
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
    return Scaffold(
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
            iconTheme: const IconThemeData(color: Colors.white),
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
                      Icon(Icons.access_time, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.startTime} - ${widget.endTime}",
                        style: const TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.timer, size: 14, color: Colors.orange),
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
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.3),
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
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      double scale = 1.0;
                      if (isRunning && isBreak) {
                        scale = 1.0 + (_pulseController.value * 0.03);
                      }
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      height: 190,
                      width: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: phaseGradient),
                        boxShadow: [
                          BoxShadow(
                            color: phaseColor.withValues(alpha: 0.3),
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
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
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
                      backgroundColor: isRunning ? Colors.orange : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: isAllCompleted ? null : toggleTimer,
                    icon: Icon(
                      isRunning ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    label: Text(
                      isRunning ? "Jeda" : "Mulai",
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
    );
  }
}
