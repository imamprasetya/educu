import 'package:educu_project/view/schedule/pomodoro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
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
    DateTime base = selectedDate;

    DateTime monday = base.subtract(Duration(days: base.weekday - 1));

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
                ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"][date.weekday -
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

  // DIALOG: Pomodoro sedang berjalan
  void _showPomodoroRunningDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.timer, size: 50, color: Colors.orange),
        content: Text(
          "Timer Pomodoro sedang berjalan!\nSelesaikan atau hentikan timer yang aktif terlebih dahulu.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColor.textPrimary(context)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4D6FFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // DIALOG: Belum waktunya
  Future<bool?> _showStartTimeDialog(DateTime startTime) {
    final List<String> months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];

    final dateStr = "${startTime.day} ${months[startTime.month - 1]} ${startTime.year}";
    final timeStr = "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.info_outline, size: 50, color: Colors.blue),
        content: Text(
          "Jadwal ini belum waktunya ($dateStr pukul $timeStr).\nTetap ingin mulai belajar sekarang?",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColor.textPrimary(context)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Batal",
              style: TextStyle(color: AppColor.textHint(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4D6FFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Lanjut", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Helper parse time "08:00" atau "08:00 PM"
  DateTime? _parseTime(String time, DateTime baseDate) {
    try {
      final cleaned = time.trim();

      if (cleaned.contains(':')) {
        final parts = cleaned.split(':');
        int hour = int.parse(parts[0]);

        // Handle AM/PM
        if (cleaned.toLowerCase().contains('pm') && hour != 12) hour += 12;
        if (cleaned.toLowerCase().contains('am') && hour == 12) hour = 0;

        final minute = int.parse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
        return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // CARD JADWAL
  Widget scheduleCard(Map<String, dynamic> data) {
    final bool isCompleted = data["completed"] == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: isCompleted
            ? Border.all(color: Colors.green.withValues(alpha: 0.4))
            : null,

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
          // SUBJECT
          Text(
            data["subject"] ?? "",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCompleted
                  ? AppColor.textHint(context)
                  : AppColor.textPrimary(context),
            ),
          ),

          const SizedBox(height: 6),

          // MATERI
          Text(
            "Topik : ${data["topic"]}",
            style: TextStyle(color: AppColor.textSecondary(context)),
          ),

          const SizedBox(height: 6),

          // JAM BELAJAR
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

          // BUTTON or SELESAI badge
          if (isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Selesai",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D6FFF),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                onPressed: () async {
                  // Check if pomodoro is already running for a DIFFERENT session
                  if (await FlutterForegroundTask.isRunningService) {
                    final runningId = await FlutterForegroundTask.getData<String>(key: 'sessionId');
                    if (runningId != null && runningId != data["id"]) {
                      _showPomodoroRunningDialog();
                      return;
                    }
                  }

                  // Check if it's too early
                  final startTimeStr = data["startTime"] ?? "";
                  final startTime = _parseTime(startTimeStr, selectedDate);
                  if (startTime != null && DateTime.now().isBefore(startTime)) {
                    final proceed = await _showStartTimeDialog(startTime);
                    if (proceed != true) return;
                  }

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PomodoroScreen(
                        subject: data["subject"] ?? "",
                        topic: data["topic"] ?? "",
                        sessionId: data["id"],
                        startTime: data["startTime"] ?? "08:00",
                        endTime: data["endTime"] ?? "09:00",
                      ),
                    ),
                  );

                  if (result == true) {
                    loadSchedule();
                  }
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
        preferredSize: const Size.fromHeight(150),

        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),

          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColor.isDark(context)
                  ? [AppColor.darkSurface, AppColor.darkCard]
                  : [AppColor.gradien1, AppColor.gradien2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Jadwal Belajar",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: AppColor.isDark(context)
                                  ? const ColorScheme.dark(
                                      primary: Color(0xFF4D6FFF),
                                      surface: Color(0xFF1E1E3A),
                                    )
                                  : const ColorScheme.light(
                                      primary: Color(0xFF4D6FFF),
                                    ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                          generateWeek();
                        });
                        loadSchedule();
                      }
                    },
                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Text(
                "Rencanakan hari ini, sukses esok hari.",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 15),

          // DATE SELECTOR
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

          // SESSION LIST
          Expanded(
            child: sessions.isEmpty
                ? Center(
                    child: Text(
                      "Tidak ada jadwal hari ini",
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
