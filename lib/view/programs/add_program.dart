import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/services/notification_service.dart';
import 'package:educu_project/models/session_model.dart';
import 'package:flutter/material.dart';

class AddProgram extends StatefulWidget {
  const AddProgram({super.key});

  @override
  State<AddProgram> createState() => _AddProgramState();
}

class _AddProgramState extends State<AddProgram> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  final TextEditingController deskController = TextEditingController();

  List<SessionData> sessions = [SessionData()];

  void _addSession() {
    setState(() {
      sessions.add(SessionData());
    });
  }

  void _removeSession(int index) {
    setState(() {
      if (sessions.length > 1) {
        sessions[index].dispose();
        sessions.removeAt(index);
      }
    });
  }

  // tanggal subject
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = picked.toString().split(' ')[0];
      setState(() {});
    }
  }

  // validasi tanggal sesi
  Future<void> _selectSessionsDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    if (startController.text.isEmpty || endController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan pilih Tanggal Mulai dan Tanggal Selesai terlebih dahulu!"),
        ),
      );
      return;
    }

    DateTime firstAllowed = DateTime.parse(startController.text);
    DateTime lastAllowed = DateTime.parse(endController.text);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstAllowed,
      firstDate: firstAllowed,
      lastDate: lastAllowed,
    );

    if (picked != null) {
      controller.text = picked.toString().split(' ')[0];
      setState(() {});
    }
  }

  // pilih waktu sesi
  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      controller.text = picked.format(context);
      setState(() {});
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

  // save data program dan session
  Future<void> _submitAndExit() async {
    if (_hasConflictingSessions()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Waktu sesi tidak boleh tumpang tindih pada tanggal yang sama."),
        ),
      );
      return;
    }

    // ambil user id yang sedang login dari Firebase
    String? userId = FirebaseService.getCurrentUid();
    if (userId == null) return;

    // insert program ke Firestore
    String programId = await FirebaseService.insertProgram({
      "userId": userId,
      "subject": subjectController.text,
      "startDate": startController.text,
      "endDate": endController.text,
      "description": deskController.text,
    });

    // insert session ke Firestore
    for (var s in sessions) {
      SessionModel session = SessionModel(
        programId: programId,
        topic: s.topicController.text,
        date: s.dateController.text,
        startTime: s.startTimeController.text,
        endTime: s.endTimeController.text,
      );

      await FirebaseService.insertSession(session);
    }

    // Reschedule notifications with new sessions
    NotificationService().scheduleAllNotifications();

    // alert berhasil
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: Text(
            "Program berhasil disimpan!",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.textPrimary(context)),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColor.logo),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    subjectController.dispose();
    startController.dispose();
    endController.dispose();
    deskController.dispose();

    for (var session in sessions) {
      session.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
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
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: const SafeArea(
            child: Row(
              children: [
                BackButton(color: Colors.white),
                Text(
                  "Tambah Program Belajar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              // input program
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.cardColor(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.shadowColor(context),
                      spreadRadius: 3,
                      blurRadius: 5,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nama Subjek",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary(context),
                      ),
                    ),

                    const SizedBox(height: 7),

                    TextFormField(
                      controller: subjectController,
                      style: TextStyle(color: AppColor.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: "Masukkan nama subjek",
                        hintStyle: TextStyle(color: AppColor.textHint(context)),
                        filled: true,
                        fillColor: AppColor.inputFill(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: startController,
                            readOnly: true,
                            onTap: () => _selectDate(context, startController),
                            style: TextStyle(color: AppColor.textPrimary(context)),
                            decoration: InputDecoration(
                              hintText: "Tanggal Mulai",
                              hintStyle: TextStyle(color: AppColor.textHint(context)),
                              filled: true,
                              fillColor: AppColor.inputFill(context),
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: AppColor.iconColor(context),
                              ),
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
                            onTap: () => _selectDate(context, endController),
                            style: TextStyle(color: AppColor.textPrimary(context)),
                            decoration: InputDecoration(
                              hintText: "Tanggal Selesai",
                              hintStyle: TextStyle(color: AppColor.textHint(context)),
                              filled: true,
                              fillColor: AppColor.inputFill(context),
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: AppColor.iconColor(context),
                              ),
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

                    Text(
                      "Deskripsi",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary(context),
                      ),
                    ),

                    const SizedBox(height: 7),

                    TextFormField(
                      controller: deskController,
                      maxLines: 4,
                      style: TextStyle(color: AppColor.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: "Masukkan deskripsi program",
                        hintStyle: TextStyle(color: AppColor.textHint(context)),
                        filled: true,
                        fillColor: AppColor.inputFill(context),
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

              // sessions title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sesi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColor.textPrimary(context),
                    ),
                  ),
                  IconButton(
                    onPressed: _addSession,
                    icon: const Icon(
                      Icons.add_circle,
                      color: AppColor.gradien2,
                      size: 32,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Column(
                children: List.generate(sessions.length, (index) {
                  final session = sessions[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: AppColor.cardColor(context),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.shadowColor(context),
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
                              "Sesi ${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            if (sessions.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeSession(index),
                              ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Topik Materi",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.textPrimary(context),
                          ),
                        ),

                        const SizedBox(height: 7),

                        TextFormField(
                          controller: session.topicController,
                          style: TextStyle(color: AppColor.textPrimary(context)),
                          decoration: InputDecoration(
                            hintText: "Masukkan topik",
                            hintStyle: TextStyle(color: AppColor.textHint(context)),
                            filled: true,
                            fillColor: AppColor.inputFill(context),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: session.dateController,
                          readOnly: true,
                          onTap: () => _selectSessionsDate(
                            context,
                            session.dateController,
                          ),
                          style: TextStyle(color: AppColor.textPrimary(context)),
                          decoration: InputDecoration(
                            hintText: "Pilih Tanggal",
                            hintStyle: TextStyle(color: AppColor.textHint(context)),
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: AppColor.iconColor(context),
                            ),
                            filled: true,
                            fillColor: AppColor.inputFill(context),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: session.startTimeController,
                                readOnly: true,
                                onTap: () => _selectTime(
                                  context,
                                  session.startTimeController,
                                ),
                                style: TextStyle(color: AppColor.textPrimary(context)),
                                decoration: InputDecoration(
                                  hintText: "Waktu Mulai",
                                  hintStyle: TextStyle(color: AppColor.textHint(context)),
                                  prefixIcon: Icon(
                                    Icons.access_time,
                                    color: AppColor.iconColor(context),
                                  ),
                                  filled: true,
                                  fillColor: AppColor.inputFill(context),
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
                                onTap: () => _selectTime(
                                  context,
                                  session.endTimeController,
                                ),
                                style: TextStyle(color: AppColor.textPrimary(context)),
                                decoration: InputDecoration(
                                  hintText: "Waktu Selesai",
                                  hintStyle: TextStyle(color: AppColor.textHint(context)),
                                  prefixIcon: Icon(
                                    Icons.access_time,
                                    color: AppColor.iconColor(context),
                                  ),
                                  filled: true,
                                  fillColor: AppColor.inputFill(context),
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
                  onPressed: _submitAndExit,
                  child: const Text(
                    "Simpan Program",
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
      ),
    );
  }
}

class SessionData {
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
