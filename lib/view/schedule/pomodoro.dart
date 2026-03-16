import 'dart:async';
import 'package:flutter/material.dart';
import '../../constant/app_color.dart';

class PomodoroScreen extends StatefulWidget {
  final String subject;
  final String topic;

  const PomodoroScreen({super.key, required this.subject, required this.topic});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int pomodoroTime = 25 * 60;

  int timeLeft = pomodoroTime;

  Timer? timer;

  bool isRunning = false;

  /// FORMAT TIME
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  /// START TIMER
  void startTimer() {
    if (isRunning) return;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();

        setState(() {
          isRunning = false;
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Pomodoro Selesai"),
            content: const Text(
              "Waktu belajar telah selesai, istirahat sebentar!",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    });

    setState(() {
      isRunning = true;
    });
  }

  /// PAUSE TIMER
  void pauseTimer() {
    timer?.cancel();

    setState(() {
      isRunning = false;
    });
  }

  /// RESET TIMER
  void resetTimer() {
    timer?.cancel();

    setState(() {
      timeLeft = pomodoroTime;
      isRunning = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F6),

      appBar: AppBar(
        title: const Text("Pomodoro Timer"),
        backgroundColor: AppColor.gradien1,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            /// SUBJECT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.subject,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Materi : ${widget.topic}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// TIMER
            Container(
              height: 220,
              width: 220,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColor.gradien1, AppColor.gradien2],
                ),
              ),

              child: Center(
                child: Text(
                  formatTime(timeLeft),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            /// BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                /// START
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),

                  onPressed: startTimer,

                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start"),
                ),

                /// PAUSE
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),

                  onPressed: pauseTimer,

                  icon: const Icon(Icons.pause),
                  label: const Text("Pause"),
                ),

                /// RESET
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),

                  onPressed: resetTimer,

                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset"),
                ),
              ],
            ),

            const SizedBox(height: 40),

            /// INFO TEXT
            const Text(
              "Focus selama 25 menit, lalu istirahat 5 menit.\nMetode ini disebut Pomodoro Technique.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
