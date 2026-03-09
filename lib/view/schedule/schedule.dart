import 'package:flutter/material.dart';
import '../../database/sqflite.dart';
import '../../models/session_model.dart';
import 'pomodoro.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    loadSchedules();
  }

  /// LOAD JADWAL DARI DATABASE
  Future<void> loadSchedules() async {
    final data = await DBHelper.getSessions();

    setState(() {
      schedules = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return const Center(
        child: Text("Tidak Ada Jadwal", style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final j = schedules[index];

        return Card(
          margin: const EdgeInsets.all(12),
          elevation: 3,
          child: ListTile(
            title: Text(
              j["topic"] ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(j["date"] ?? ""),
                Text("${j["startTime"]} - ${j["endTime"]}"),
              ],
            ),

            trailing: const Icon(Icons.circle_outlined, color: Colors.grey),

            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(j["topic"] ?? ""),

                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(j["date"] ?? ""),

                        const SizedBox(height: 5),

                        Text("${j["startTime"]} - ${j["endTime"]}"),

                        const SizedBox(height: 20),

                        const Icon(
                          Icons.play_circle_fill,
                          size: 60,
                          color: Colors.blue,
                        ),
                      ],
                    ),

                    actions: [
                      ElevatedButton(
                        child: const Text("Mulai Belajar"),
                        onPressed: () {
                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PomodoroScreen(topic: j["topic"]),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
