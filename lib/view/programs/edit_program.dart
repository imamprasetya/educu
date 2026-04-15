import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/models/program_model.dart';
import 'package:educu_project/models/session_model.dart';
import 'package:flutter/material.dart';

class EditProgram extends StatefulWidget {
  final ProgramModel program;

  const EditProgram({super.key, required this.program});

  @override
  State<EditProgram> createState() => _EditProgramState();
}

class _EditProgramState extends State<EditProgram> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  final TextEditingController deskController = TextEditingController();

  List<SessionData> sessions = [];
  List<String> originalSessionIds = [];

  @override
  void initState() {
    super.initState();

    subjectController.text = widget.program.subject;
    startController.text = widget.program.startDate;
    endController.text = widget.program.endDate;
    deskController.text = widget.program.description;

    loadSessions();
  }

  // DATE PICKER
  Future<void> pickDate(TextEditingController controller) async {
    DateTime startDate = DateTime.parse(startController.text);
    DateTime endDate = DateTime.parse(endController.text);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: startDate,
      lastDate: endDate,
    );

    if (pickedDate != null) {
      controller.text =
          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
    }
  }

  // TIME PICKER
  Future<void> pickTime(TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      controller.text = pickedTime.format(context);
    }
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

  bool _hasConflictingSessions() {
    for (var i = 0; i < sessions.length; i++) {
      final first = sessions[i];
      if (first.dateController.text.isEmpty ||
          first.startTimeController.text.isEmpty ||
          first.endTimeController.text.isEmpty) {
        continue;
      }

      final firstDate = first.dateController.text;
      final firstStart = _parseTime(first.startTimeController.text);
      final firstEnd = _parseTime(first.endTimeController.text);
      if (firstStart == null || firstEnd == null) continue;

      for (var j = i + 1; j < sessions.length; j++) {
        final second = sessions[j];
        if (second.dateController.text != firstDate) continue;
        if (second.startTimeController.text.isEmpty ||
            second.endTimeController.text.isEmpty) {
          continue;
        }

        final secondStart = _parseTime(second.startTimeController.text);
        final secondEnd = _parseTime(second.endTimeController.text);
        if (secondStart == null || secondEnd == null) continue;

        final overlap =
            firstStart.isBefore(secondEnd) && secondStart.isBefore(firstEnd);
        if (overlap) {
          return true;
        }
      }
    }
    return false;
  }

  // LOAD SESSION from Firestore
  Future<void> loadSessions() async {
    final data = await FirebaseService.getSessions(widget.program.id!);

    originalSessionIds = data
        .where((s) => s['id'] != null)
        .map<String>((s) => s['id'] as String)
        .toList();

    sessions = data.map((s) {
      final session = SessionData();

      session.id = s['id'] as String?;
      session.completed = s['completed'] == true;
      session.topicController.text = s["topic"];
      session.dateController.text = s["date"];
      session.startTimeController.text = s["startTime"];
      session.endTimeController.text = s["endTime"];

      return session;
    }).toList();

    setState(() {});
  }

  // TAMBAH SESSION
  void addSession() {
    setState(() {
      sessions.add(SessionData());
    });
  }

  // HAPUS SESSION
  void removeSession(int index) {
    setState(() {
      sessions[index].dispose();
      sessions.removeAt(index);
    });
  }

  // UPDATE PROGRAM
  Future<void> updateProgram() async {
    if (_hasConflictingSessions()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session times cannot overlap on the same date."),
        ),
      );
      return;
    }

    String programId = widget.program.id!;

    await FirebaseService.updateProgram(programId, {
      "subject": subjectController.text,
      "startDate": startController.text,
      "endDate": endController.text,
      "description": deskController.text,
    });

    final currentIds = sessions
        .where((s) => s.id != null)
        .map((s) => s.id!)
        .toList();

    final removedIds = originalSessionIds
        .where((id) => !currentIds.contains(id))
        .toList();

    for (var sessionId in removedIds) {
      await FirebaseService.deleteSession(sessionId);
    }

    for (var s in sessions) {
      if (s.id != null) {
        await FirebaseService.updateSession(s.id!, {
          "topic": s.topicController.text,
          "date": s.dateController.text,
          "startTime": s.startTimeController.text,
          "endTime": s.endTimeController.text,
          "completed": s.completed,
        });
      } else {
        SessionModel session = SessionModel(
          programId: programId,
          topic: s.topicController.text,
          date: s.dateController.text,
          startTime: s.startTimeController.text,
          endTime: s.endTimeController.text,
        );

        await FirebaseService.insertSession(session);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Program updated successfully.")),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    subjectController.dispose();
    startController.dispose();
    endController.dispose();
    deskController.dispose();

    for (var s in sessions) {
      s.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Edit Study Program",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColor.gradien1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PROGRAM
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Subject Name",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 7),

                  TextFormField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColor.box1,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // START & END DATE
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: startController,
                          readOnly: true,
                          onTap: () => pickDate(startController),
                          decoration: InputDecoration(
                            hintText: "Start Date",
                            suffixIcon: const Icon(Icons.calendar_today),
                            filled: true,
                            fillColor: AppColor.box1,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: TextFormField(
                          controller: endController,
                          readOnly: true,
                          onTap: () => pickDate(endController),
                          decoration: InputDecoration(
                            hintText: "End Date",
                            suffixIcon: const Icon(Icons.calendar_today),
                            filled: true,
                            fillColor: AppColor.box1,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 7),

                  TextFormField(
                    controller: deskController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColor.box1,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// SESSION TITLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Sessions",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                IconButton(
                  onPressed: addSession,
                  icon: Icon(
                    Icons.add_circle,
                    color: AppColor.gradien2,
                    size: 32,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// SESSION LIST
            Column(
              children: List.generate(sessions.length, (index) {
                final session = sessions[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Session ${index + 1}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeSession(index),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// TOPIC
                      TextFormField(
                        controller: session.topicController,
                        decoration: InputDecoration(
                          hintText: "Topic",
                          filled: true,
                          fillColor: AppColor.box1,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// DATE
                      TextFormField(
                        controller: session.dateController,
                        readOnly: true,
                        onTap: () => pickDate(session.dateController),
                        decoration: InputDecoration(
                          hintText: "Date",
                          suffixIcon: const Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: AppColor.box1,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// TIME
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: session.startTimeController,
                              readOnly: true,
                              onTap: () =>
                                  pickTime(session.startTimeController),
                              decoration: InputDecoration(
                                hintText: "Start Time",
                                suffixIcon: const Icon(Icons.access_time),
                                filled: true,
                                fillColor: AppColor.box1,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: TextFormField(
                              controller: session.endTimeController,
                              readOnly: true,
                              onTap: () => pickTime(session.endTimeController),
                              decoration: InputDecoration(
                                hintText: "End Time",
                                suffixIcon: const Icon(Icons.access_time),
                                filled: true,
                                fillColor: AppColor.box1,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            /// UPDATE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.gradien1,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                onPressed: updateProgram,

                child: const Text(
                  "Update Program",
                  style: TextStyle(
                    color: Colors.white,
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

class SessionData {
  String? id;
  bool completed = false;
  TextEditingController topicController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  void dispose() {
    topicController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
  }
}
