import 'package:flutter/material.dart';
import '../../constant/app_color.dart';
import '../../database/sqflite.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> sessions = [];
  String selectedDate = "";

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    selectedDate = "${now.year}-${now.month}-${now.day}";

    loadSchedule();
  }

  /// LOAD DATA SESSION
  Future<void> loadSchedule() async {
    final db = await DBHelper.db();

    final data = await db.rawQuery(
      '''
    SELECT session.*, program.subject
    FROM session
    JOIN program ON session.programId = program.id
    WHERE session.date = ?
    ''',
      [selectedDate],
    );

    setState(() {
      sessions = data;
    });
  }

  /// FORMAT DATE
  String formatDate(int day) {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month}-$day";
  }

  /// DAY ITEM
  Widget dayItem(String day, int date) {
    bool active = selectedDate == formatDate(date);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = formatDate(date);
        });

        loadSchedule();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4D6FFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(
              day,
              style: TextStyle(
                color: active ? Colors.white : Colors.black,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.toString(),
              style: TextStyle(
                color: active ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CARD
  Widget scheduleCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Colors.blue),
              const SizedBox(width: 8),

              Text(
                data["subject"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "Topic: ${data["topic"]}",
            style: const TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 4),

          Text(
            "${data["startTime"]} - ${data["endTime"]}",
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D6FFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),

              onPressed: () {},

              child: const Text(
                "Start Study",
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
      backgroundColor: const Color(0xFFF3F3F6),

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

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),

            /// DATE SELECTOR
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),

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

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  dayItem("Mon", 6),
                  dayItem("Tue", 7),
                  dayItem("Wed", 8),
                  dayItem("Thu", 9),
                  dayItem("Fri", 10),
                  dayItem("Sat", 11),
                  dayItem("Sun", 12),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST SESSION
            sessions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No schedule today"),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: sessions.length,

                    itemBuilder: (context, index) {
                      final data = sessions[index];

                      return scheduleCard(data);
                    },
                  ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
