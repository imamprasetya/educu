import 'dart:async';
import 'package:educu_project/view/schedule/schedule.dart';
import 'package:flutter/material.dart';
import '../../models/program_model.dart';

class PomodoroScreen extends StatefulWidget {
  final JadwalScreen jadwal;

  const PomodoroScreen({super.key, required this.jadwal});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int time = 1500;
  Timer? timer;

  void start() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (time > 0) {
        setState(() => time--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int menit = time ~/ 60;
    int detik = time % 60;

    return Scaffold(
      appBar: AppBar(title: const Text("Pomodoro Timer")),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$menit:$detik",
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            ElevatedButton(onPressed: start, child: const Text("Start")),

            ElevatedButton(
              onPressed: () {
                widget.jadwal.selesai = true;
                Navigator.pop(context);
              },
              child: const Text("Selesai"),
            ),
          ],
        ),
      ),
    );
  }
}
