import 'dart:async';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/services/notification_service.dart';
import 'package:flutter/material.dart';
import '../../constant/app_color.dart';

class PomodoroScreen extends StatefulWidget {
  final String subject;
  final String topic;
  final String? sessionId;
  final int durationMinutes;

  const PomodoroScreen({
    super.key,
    required this.subject,
    required this.topic,
    this.sessionId,
    this.durationMinutes = 25,
  });

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  late int totalSeconds;
  late int timeLeft;

  Timer? timer;
  bool isRunning = false;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    totalSeconds = widget.durationMinutes * 60;
    timeLeft = totalSeconds;
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

  // START TIMER
  void startTimer() {
    if (isRunning || isCompleted) return;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          isRunning = false;
          isCompleted = true;
        });

        _showCompletedDialog();
      }
    });

    setState(() {
      isRunning = true;
    });
  }

  // PAUSE TIMER
  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  // RESET TIMER
  void resetTimer() {
    timer?.cancel();
    setState(() {
      timeLeft = totalSeconds;
      isRunning = false;
      isCompleted = false;
    });
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
      isCompleted = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session completed! Great job! 🎉"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
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
    super.dispose();
  }

  double get progress {
    if (totalSeconds == 0) return 0;
    return 1 - (timeLeft / totalSeconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Study Timer",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColor.gradien1,
      ),

      body: Padding(
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
                    "Topic : ${widget.topic}",
                    style: TextStyle(color: AppColor.textSecondary(context)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Duration : ${widget.durationMinutes} minutes",
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

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
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: AppColor.isDark(context)
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(
                        isCompleted ? Colors.green : AppColor.gradien2,
                      ),
                    ),
                  ),
                  Container(
                    height: 190,
                    width: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isCompleted
                            ? [Colors.green.shade400, Colors.green.shade700]
                            : [AppColor.gradien1, AppColor.gradien2],
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 60,
                              color: Colors.white,
                            )
                          : Text(
                              formatTime(timeLeft),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // CONTROL BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // START
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: isCompleted ? null : startTimer,
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text(
                    "Start",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                // PAUSE
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: pauseTimer,
                  icon: const Icon(Icons.pause, color: Colors.white),
                  label: const Text(
                    "Pause",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                // RESET
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: resetTimer,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    "Reset",
                    style: TextStyle(color: Colors.white),
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
                  backgroundColor: isCompleted ? Colors.grey : AppColor.gradien1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: isCompleted ? null : _markComplete,
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: Text(
                  isCompleted ? "Sudah Selesai" : "Selesai",
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
