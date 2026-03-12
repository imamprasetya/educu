import 'package:flutter/material.dart';

class PomodoroScreen extends StatelessWidget {
  final String subject;
  final String topic;

  const PomodoroScreen({super.key, required this.subject, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pomodoro Timer")),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              subject,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              topic,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 40),

            const Text(
              "25:00",
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: () {}, child: const Text("Start Timer")),
          ],
        ),
      ),
    );
  }
}
