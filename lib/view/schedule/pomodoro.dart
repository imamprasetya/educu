import 'package:flutter/material.dart';

class PomodoroScreen extends StatelessWidget {
  final String subject;
  final String topic;

  PomodoroScreen({super.key, required this.subject, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pomodoro Timer")),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              subject,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(topic, style: TextStyle(fontSize: 16, color: Colors.grey)),

            SizedBox(height: 40),

            Text(
              "25:00",
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            ElevatedButton(onPressed: () {}, child: Text("Start Timer")),
          ],
        ),
      ),
    );
  }
}
