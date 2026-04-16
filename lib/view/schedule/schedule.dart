import 'package:educu_project/view/schedule/pomodoro.dart';
import 'package:flutter/material.dart';
import '../../constant/app_color.dart';
import '../../services/firebase_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> sessions = [];

  DateTime today = DateTime.now();
  DateTime selectedDate = DateTime.now();

  List<DateTime> weekDays = [];

  @override
  void initState() {
    super.initState();
    generateWeek();
    loadSchedule();
  }

  // GENERATE WEEK
  void generateWeek() {
    DateTime now = DateTime.now();

    DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    weekDays = [];

    for (int i = 0; i < 7; i++) {
      weekDays.add(monday.add(Duration(days: i)));
    }
  }

  // LOAD SESSION FROM FIRESTORE
  Future<void> loadSchedule() async {
    String date =
        "${selectedDate.year.toString().padLeft(4, '0')}-"
        "${selectedDate.month.toString().padLeft(2, '0')}-"
        "${selectedDate.day.toString().padLeft(2, '0')}";

    final data = await FirebaseService.getSessionsByDate(date);

    setState(() {
      sessions = data;
    });
  }

  // DATE ITEM
  Widget dayItem(DateTime date) {
    bool isSelected =
        date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;

    bool isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    Color bgColor = Colors.transparent;
    Color textColor = AppColor.textPrimary(context);

    if (isSelected) {
      bgColor = const Color(0xFF4D6FFF);
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = const Color(0x334D6FFF);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDate = date;
          });

          loadSchedule();
        },

        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),

          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),

          child: Column(
            children: [
              Text(
                ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][date.weekday -
                    1],
                style: TextStyle(fontSize: 12, color: textColor),
              ),

              const SizedBox(height: 4),

              Text(
                date.day.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// CARD JADWAL
  Widget scheduleCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),

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
          /// SUBJECT
          Text(
            data["subject"] ?? "",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary(context),
            ),
          ),

          const SizedBox(height: 6),

          /// MATERI
          Text(
            "Topic : ${data["topic"]}",
            style: TextStyle(color: AppColor.textSecondary(context)),
          ),

          const SizedBox(height: 6),

          /// JAM BELAJAR
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.blue),

              const SizedBox(width: 5),

              Text(
                "${data["startTime"]} - ${data["endTime"]}",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          /// BUTTON START STUDY
          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D6FFF),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PomodoroScreen(
                      subject: data["subject"] ?? "",
                      topic: data["topic"] ?? "",
                      sessionId: data["id"],
                    ),
                  ),
                );
              },

              child: const Text(
                "Mulai Belajar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),

        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),

          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.gradien1, AppColor.gradien2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),

          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Study Schedule",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 5),

              Text(
                "Plan today, succeed tomorrow.",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 15),

          /// DATE SELECTOR
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),

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

            child: Row(
              children: weekDays.map((date) => dayItem(date)).toList(),
            ),
          ),

          const SizedBox(height: 20),

          /// SESSION LIST
          Expanded(
            child: sessions.isEmpty
                ? Center(
                    child: Text(
                      "No schedule today",
                      style: TextStyle(color: AppColor.textHint(context)),
                    ),
                  )
                : ListView.builder(
                    itemCount: sessions.length,

                    itemBuilder: (context, index) {
                      final data = sessions[index];

                      return scheduleCard(data);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
