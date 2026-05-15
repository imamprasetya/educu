import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/services/notification_service.dart';
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

  // Format tanggal ke format Indonesia (dd/MM/yyyy)
  String _formatDateIndo(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Parse tanggal Indonesia (dd/MM/yyyy) ke DateTime
  DateTime _parseDateIndo(String dateStr) {
    final parts = dateStr.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  // Convert ISO (yyyy-MM-dd) ke format Indonesia (dd/MM/yyyy)
  String _isoToIndo(String isoDate) {
    final dt = DateTime.parse(isoDate);
    return _formatDateIndo(dt);
  }

  // Convert tanggal Indonesia ke ISO (yyyy-MM-dd) untuk storage
  String _indoToIso(String dateStr) {
    final dt = _parseDateIndo(dateStr);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  // Format waktu ke 24 jam (HH:mm)
  String _formatTime24(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();

    subjectController.text = widget.program.subject;
    startController.text = _isoToIndo(widget.program.startDate);
    endController.text = _isoToIndo(widget.program.endDate);
    deskController.text = widget.program.description;

    loadSessions();
  }

  // DATE PICKER untuk Tanggal Mulai
  Future<void> pickStartDate() async {
    DateTime startDate = _parseDateIndo(startController.text);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      startController.text = _formatDateIndo(pickedDate);
    }
  }

  // DATE PICKER untuk Tanggal Selesai (boleh tanggal kapanpun setelah tanggal mulai)
  Future<void> pickEndDate() async {
    DateTime startDate = _parseDateIndo(startController.text);
    DateTime endDate = _parseDateIndo(endController.text);

    // initialDate harus >= firstDate
    DateTime initialDate = endDate.isBefore(startDate) ? startDate : endDate;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: startDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      endController.text = _formatDateIndo(pickedDate);
    }
  }

  // DATE PICKER untuk Sesi (dibatasi antara tanggal mulai dan tanggal selesai)
  Future<void> pickSessionDate(TextEditingController controller) async {
    DateTime startDate = _parseDateIndo(startController.text);
    DateTime endDate = _parseDateIndo(endController.text);

    DateTime initialDate;
    if (controller.text.isNotEmpty) {
      initialDate = _parseDateIndo(controller.text);
      if (initialDate.isBefore(startDate)) initialDate = startDate;
      if (initialDate.isAfter(endDate)) initialDate = endDate;
    } else {
      initialDate = startDate;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: startDate,
      lastDate: endDate,
    );

    if (pickedDate != null) {
      controller.text = _formatDateIndo(pickedDate);
    }
  }

  // pilih waktu mulai sesi
  Future<void> pickStartTime(
    TextEditingController controller, {
    int? sessionIndex,
  }) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.text.isNotEmpty
          ? TimeOfDay(
              hour: int.parse(controller.text.split(':')[0]),
              minute: int.parse(controller.text.split(':')[1]),
            )
          : TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final previousValue = controller.text;
      controller.text = _formatTime24(picked);

      // Cek konflik jika end time sudah diisi
      if (sessionIndex != null) {
        final conflict = _getTimeConflict(sessionIndex);
        if (conflict != null) {
          controller.text = previousValue;
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Waktu bertabrakan dengan $conflict!"),
            ),
          );
          return;
        }
      }

      setState(() {});

      // Jika ini sesi pertama dan ada sesi lain, tanya user
      if (sessionIndex == 0 && sessions.length > 1) {
        await _showDefaultTimeDialog('start', _formatTime24(picked));
      }
    }
  }

  // pilih waktu selesai sesi - tidak bisa sebelum waktu mulai
  Future<void> pickEndTime(
    TextEditingController controller,
    TextEditingController startTimeController, {
    int? sessionIndex,
  }) async {
    if (startTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan pilih Waktu Mulai terlebih dahulu!"),
        ),
      );
      return;
    }

    final startParts = startTimeController.text.split(':');
    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    final startTimeOfDay = TimeOfDay(hour: startHour, minute: startMinute);

    TimeOfDay initialTime = startTimeOfDay;
    if (controller.text.isNotEmpty) {
      final endParts = controller.text.split(':');
      initialTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );
    }

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Validasi: waktu selesai harus setelah waktu mulai
      final pickedMinutes = picked.hour * 60 + picked.minute;
      final startMinutes = startHour * 60 + startMinute;

      if (pickedMinutes <= startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Waktu Selesai harus setelah Waktu Mulai (${startTimeController.text})!",
            ),
          ),
        );
        return;
      }

      final previousValue = controller.text;
      controller.text = _formatTime24(picked);

      // Cek konflik dengan sesi lain
      if (sessionIndex != null) {
        final conflict = _getTimeConflict(sessionIndex);
        if (conflict != null) {
          controller.text = previousValue;
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Waktu bertabrakan dengan $conflict!"),
            ),
          );
          return;
        }
      }

      setState(() {});

      // Jika ini sesi pertama dan ada sesi lain, tanya user
      if (sessionIndex == 0 && sessions.length > 1) {
        await _showDefaultTimeDialog('end', _formatTime24(picked));
      }
    }
  }

  // Cek konflik waktu sesi dengan sesi lain pada tanggal yang sama
  String? _getTimeConflict(int currentIndex) {
    final current = sessions[currentIndex];
    if (current.dateController.text.isEmpty ||
        current.startTimeController.text.isEmpty ||
        current.endTimeController.text.isEmpty) {
      return null;
    }

    final currentDate = current.dateController.text;
    final currentStart = _parseTime(current.startTimeController.text);
    final currentEnd = _parseTime(current.endTimeController.text);
    if (currentStart == null || currentEnd == null) return null;

    for (var i = 0; i < sessions.length; i++) {
      if (i == currentIndex) continue;
      final other = sessions[i];
      if (other.dateController.text != currentDate) continue;
      if (other.startTimeController.text.isEmpty ||
          other.endTimeController.text.isEmpty) {
        continue;
      }

      final otherStart = _parseTime(other.startTimeController.text);
      final otherEnd = _parseTime(other.endTimeController.text);
      if (otherStart == null || otherEnd == null) continue;

      final overlap =
          currentStart.isBefore(otherEnd) && otherStart.isBefore(currentEnd);
      if (overlap) {
        return 'Sesi ${i + 1} (${other.dateController.text}, ${other.startTimeController.text} - ${other.endTimeController.text})';
      }
    }

    return null;
  }

  // Dialog untuk menjadikan jam default ke sesi lain
  Future<void> _showDefaultTimeDialog(
    String fieldType,
    String timeValue,
  ) async {
    final fieldLabel = fieldType == 'start' ? 'Waktu Mulai' : 'Waktu Selesai';
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.access_time_filled,
                color: AppColor.gradien2,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Jadikan Default?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColor.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: AppColor.textSecondary(context),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: "Apakah "),
                    TextSpan(
                      text: "$fieldLabel ($timeValue)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary(context),
                      ),
                    ),
                    TextSpan(
                      text:
                          " ingin dijadikan default untuk semua sesi lainnya?",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Anda tetap bisa mengubah jam di masing-masing sesi.",
                style: TextStyle(
                  color: AppColor.textHint(context),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Tidak",
                style: TextStyle(color: AppColor.textSecondary(context)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.gradien1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Ya, Jadikan Default",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() {
        for (var i = 1; i < sessions.length; i++) {
          if (fieldType == 'start') {
            sessions[i].startTimeController.text = timeValue;
          } else {
            sessions[i].endTimeController.text = timeValue;
          }
        }
      });
    }
  }

  DateTime? _parseTime(String time) {
    try {
      final cleaned = time.trim();
      final parts = cleaned.split(':');
      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].trim());
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
      session.dateController.text = _isoToIndo(s["date"]);
      session.startTimeController.text = s["startTime"];
      session.endTimeController.text = s["endTime"];

      return session;
    }).toList();

    // Urutkan sesi berdasarkan tanggal dan jam terawal
    sessions.sort((a, b) {
      // Bandingkan tanggal
      if (a.dateController.text.isNotEmpty && b.dateController.text.isNotEmpty) {
        final dateA = _parseDateIndo(a.dateController.text);
        final dateB = _parseDateIndo(b.dateController.text);
        final dateComparison = dateA.compareTo(dateB);
        if (dateComparison != 0) return dateComparison;
      }

      // Jika tanggal sama, bandingkan waktu mulai
      final timeA = _parseTime(a.startTimeController.text);
      final timeB = _parseTime(b.startTimeController.text);
      if (timeA != null && timeB != null) {
        return timeA.compareTo(timeB);
      }
      return 0;
    });

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

  // Cari tanggal yang tidak ada sesi
  List<String> _getUncoveredDates() {
    if (startController.text.isEmpty || endController.text.isEmpty) return [];

    DateTime start = _parseDateIndo(startController.text);
    DateTime end = _parseDateIndo(endController.text);

    // Kumpulkan semua tanggal sesi (dalam format dd/MM/yyyy)
    Set<String> sessionDates = {};
    for (var s in sessions) {
      if (s.dateController.text.isNotEmpty) {
        sessionDates.add(s.dateController.text);
      }
    }

    // Cari tanggal yang tidak terisi
    List<String> uncovered = [];
    DateTime current = start;
    while (!current.isAfter(end)) {
      String formatted = _formatDateIndo(current);
      if (!sessionDates.contains(formatted)) {
        uncovered.add(formatted);
      }
      current = current.add(const Duration(days: 1));
    }

    return uncovered;
  }

  // Dialog konfirmasi tanggal kosong
  Future<bool> _showUncoveredDatesDialog(List<String> uncoveredDates) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Tanggal Kosong",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ada ${uncoveredDates.length} tanggal yang belum memiliki sesi:",
                style: TextStyle(color: AppColor.textSecondary(context)),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: uncoveredDates.map((date) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Apakah Anda tetap ingin menyimpan?",
                style: TextStyle(
                  color: AppColor.textPrimary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.gradien1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Tetap Simpan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  // UPDATE PROGRAM
  Future<void> updateProgram() async {
    // Validasi field program
    List<String> emptyFields = [];
    if (subjectController.text.trim().isEmpty) {
      emptyFields.add("Nama Subjek");
    }
    if (startController.text.isEmpty) {
      emptyFields.add("Tanggal Mulai");
    }
    if (endController.text.isEmpty) {
      emptyFields.add("Tanggal Selesai");
    }

    // Validasi field setiap sesi
    for (var i = 0; i < sessions.length; i++) {
      final s = sessions[i];
      final sesiLabel = "Sesi ${i + 1}";
      if (s.topicController.text.trim().isEmpty) {
        emptyFields.add("$sesiLabel - Topik Materi");
      }
      if (s.dateController.text.isEmpty) {
        emptyFields.add("$sesiLabel - Tanggal");
      }
      if (s.startTimeController.text.isEmpty) {
        emptyFields.add("$sesiLabel - Waktu Mulai");
      }
      if (s.endTimeController.text.isEmpty) {
        emptyFields.add("$sesiLabel - Waktu Selesai");
      }
    }

    if (emptyFields.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Data Belum Lengkap",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColor.textPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Silakan lengkapi data berikut:",
                  style: TextStyle(
                    color: AppColor.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: emptyFields.map((field) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.red.withOpacity(0.7),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  field,
                                  style: TextStyle(
                                    color: AppColor.textPrimary(context),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.gradien1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Mengerti",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_hasConflictingSessions()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Waktu sesi tidak boleh tumpang tindih pada tanggal dan jam yang sama.",
          ),
        ),
      );
      return;
    }

    // Cek tanggal yang tidak ada sesi
    final uncoveredDates = _getUncoveredDates();
    if (uncoveredDates.isNotEmpty) {
      final confirmed = await _showUncoveredDatesDialog(uncoveredDates);
      if (!confirmed) return;
    }

    String programId = widget.program.id!;

    await FirebaseService.updateProgram(programId, {
      "subject": subjectController.text,
      "startDate": _indoToIso(startController.text),
      "endDate": _indoToIso(endController.text),
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
          "date": _indoToIso(s.dateController.text),
          "startTime": s.startTimeController.text,
          "endTime": s.endTimeController.text,
          "completed": s.completed,
        });
      } else {
        SessionModel session = SessionModel(
          programId: programId,
          topic: s.topicController.text,
          date: _indoToIso(s.dateController.text),
          startTime: s.startTimeController.text,
          endTime: s.endTimeController.text,
        );

        await FirebaseService.insertSession(session);
      }
    }

    // Reschedule notifications after update
    NotificationService().scheduleAllNotifications();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Program berhasil diperbarui.")),
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

  // Dialog konfirmasi keluar
  Future<bool> _showExitConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Keluar?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColor.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "Perubahan yang belum disimpan akan hilang. Apakah Anda yakin ingin keluar?",
            style: TextStyle(
              color: AppColor.textSecondary(context),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Batal",
                style: TextStyle(color: AppColor.textSecondary(context)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Ya, Keluar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmDialog();
        if (shouldExit && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            final shouldExit = await _showExitConfirmDialog();
            if (shouldExit && mounted) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          "Edit Program Belajar",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColor.isDark(context)
            ? AppColor.darkSurface
            : AppColor.gradien1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PROGRAM
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.cardColor(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowColor(context),
                    blurRadius: 6,
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
                      filled: true,
                      fillColor: AppColor.inputFill(context),
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
                          onTap: () => pickStartDate(),
                          style: TextStyle(
                            color: AppColor.textPrimary(context),
                          ),
                          decoration: InputDecoration(
                            hintText: "Tanggal Mulai",
                            hintStyle: TextStyle(
                              color: AppColor.textHint(context),
                            ),
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: AppColor.iconColor(context),
                            ),
                            filled: true,
                            fillColor: AppColor.inputFill(context),
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
                          onTap: () => pickEndDate(),
                          style: TextStyle(
                            color: AppColor.textPrimary(context),
                          ),
                          decoration: InputDecoration(
                            hintText: "Tanggal Selesai",
                            hintStyle: TextStyle(
                              color: AppColor.textHint(context),
                            ),
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: AppColor.iconColor(context),
                            ),
                            filled: true,
                            fillColor: AppColor.inputFill(context),
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

            /// SESSION TITLE
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
                  onPressed: addSession,
                  icon: const Icon(
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
                        style: TextStyle(color: AppColor.textPrimary(context)),
                        decoration: InputDecoration(
                          hintText: "Topik",
                          hintStyle: TextStyle(
                            color: AppColor.textHint(context),
                          ),
                          filled: true,
                          fillColor: AppColor.inputFill(context),
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
                        onTap: () => pickSessionDate(session.dateController),
                        style: TextStyle(color: AppColor.textPrimary(context)),
                        decoration: InputDecoration(
                          hintText: "Tanggal",
                          hintStyle: TextStyle(
                            color: AppColor.textHint(context),
                          ),
                          suffixIcon: Icon(
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

                      const SizedBox(height: 10),

                      /// TIME
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: session.startTimeController,
                              readOnly: true,
                              onTap: () => pickStartTime(
                                  session.startTimeController,
                                  sessionIndex: index,
                                ),
                              style: TextStyle(
                                color: AppColor.textPrimary(context),
                              ),
                              decoration: InputDecoration(
                                hintText: "Waktu Mulai",
                                hintStyle: TextStyle(
                                  color: AppColor.textHint(context),
                                ),
                                suffixIcon: Icon(
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
                              onTap: () => pickEndTime(
                                  session.endTimeController,
                                  session.startTimeController,
                                  sessionIndex: index,
                                ),
                              style: TextStyle(
                                color: AppColor.textPrimary(context),
                              ),
                              decoration: InputDecoration(
                                hintText: "Waktu Selesai",
                                hintStyle: TextStyle(
                                  color: AppColor.textHint(context),
                                ),
                                suffixIcon: Icon(
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
                  "Perbarui Program",
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
