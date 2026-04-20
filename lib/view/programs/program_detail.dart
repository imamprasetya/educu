import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/models/session_model.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/view/schedule/pomodoro.dart';
import 'package:flutter/material.dart';
import '../../models/program_model.dart';

class ProgramDetail extends StatefulWidget {
  final ProgramModel program;

  const ProgramDetail({super.key, required this.program});

  @override
  State<ProgramDetail> createState() => _ProgramDetailState();
}

class _ProgramDetailState extends State<ProgramDetail> {
  List<SessionModel> sessions = [];
  bool isLoading = true;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    final data = await FirebaseService.getSessionModels(widget.program.id!);
    final prog = await FirebaseService.getProgramProgress(widget.program.id!);

    data.sort((a, b) {
      final dateA = DateTime.tryParse(a.date);
      final dateB = DateTime.tryParse(b.date);
      if (dateA != null && dateB != null) {
        final dateComparison = dateA.compareTo(dateB);
        if (dateComparison != 0) return dateComparison;
      } else if (dateA != null) {
        return -1;
      } else if (dateB != null) {
        return 1;
      }

      final startA = _parseTime(a.startTime);
      final startB = _parseTime(b.startTime);
      if (startA != null && startB != null) {
        return startA.compareTo(startB);
      }
      return 0;
    });

    setState(() {
      sessions = data;
      progress = prog;
      isLoading = false;
    });
  }

  DateTime? _parseTime(String time) {
    try {
      final lower = time.toLowerCase().trim();
      final isPM = lower.contains('pm');
      final isAM = lower.contains('am');
      final cleaned = lower.replaceAll(RegExp(r'[ap]m'), '').trim();
      final parts = cleaned.split(':');
      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].trim());
      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;
      return DateTime(2000, 1, 1, hour, minute);
    } catch (_) {
      return null;
    }
  }

  // Hitung durasi program
  String _getDuration() {
    try {
      final start = DateTime.parse(widget.program.startDate);
      final end = DateTime.parse(widget.program.endDate);
      final diff = end.difference(start).inDays;
      return "$diff hari";
    } catch (_) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    final program = widget.program;
    final pct = (progress * 100).toInt();
    final completedCount = sessions.where((s) => s.completed).length;

    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColor.isDark(context)
                  ? [AppColor.darkSurface, AppColor.darkCard]
                  : [AppColor.gradien2, AppColor.gradien1],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      program.subject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PROGRAM INFO CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.isDark(context)
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Deskripsi",
                            style: TextStyle(
                              color: AppColor.textSecondary(context),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            program.description.isNotEmpty
                                ? program.description
                                : "-",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColor.textPrimary(context),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Rentang Waktu",
                                      style: TextStyle(
                                        color: AppColor.textSecondary(context),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${program.startDate} - ${program.endDate}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColor.textPrimary(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Durasi",
                                    style: TextStyle(
                                      color: AppColor.textSecondary(context),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getDuration(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColor.textPrimary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Progress
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Progres ($completedCount/${sessions.length})",
                                style: TextStyle(
                                  color: AppColor.textSecondary(context),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "$pct%",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: progress >= 1.0
                                      ? Colors.green
                                      : Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: AppColor.isDark(context)
                                  ? Colors.grey.shade800
                                  : const Color(0xFFDBD8FF),
                              valueColor: AlwaysStoppedAnimation(
                                progress >= 1.0
                                    ? Colors.green
                                    : Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // SESSIONS TITLE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sesi",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColor.textPrimary(context),
                          ),
                        ),
                        Text(
                          "$completedCount/${sessions.length} selesai",
                          style: TextStyle(
                            color: AppColor.textHint(context),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // SESSION LIST
                    if (sessions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(30),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColor.cardColor(context),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            "Belum ada sesi",
                            style: TextStyle(
                              color: AppColor.textHint(context),
                            ),
                          ),
                        ),
                      )
                    else
                      ...sessions.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final session = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColor.cardColor(context),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: session.completed
                                  ? Colors.green.withValues(alpha: 0.4)
                                  : AppColor.borderColor(context),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.shadowColor(context),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Session number indicator
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: session.completed
                                      ? Colors.green
                                      : AppColor.isDark(context)
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                ),
                                child: Center(
                                  child: session.completed
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                      : Text(
                                          "${idx + 1}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.textSecondary(
                                              context,
                                            ),
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Session info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.topic,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        decoration: session.completed
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: session.completed
                                            ? AppColor.textHint(context)
                                            : AppColor.textPrimary(context),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: AppColor.textHint(context),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          session.date,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColor.textHint(context),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color: AppColor.textHint(context),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${session.startTime} - ${session.endTime}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColor.textHint(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Status / action
                              if (session.completed)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Selesai",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else
                                SizedBox(
                                  height: 30,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.gradien2,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PomodoroScreen(
                                            subject: program.subject,
                                            topic: session.topic,
                                            sessionId: session.id,
                                            durationMinutes:
                                                session.durationMinutes,
                                          ),
                                        ),
                                      );

                                      if (result == true) {
                                        loadSessions();
                                      }
                                    },
                                    child: const Text(
                                      "Mulai",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }
}
