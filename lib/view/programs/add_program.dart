import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/services/notification_service.dart';
import 'package:educu_project/models/session_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

  // Format tanggal ke format Indonesia (dd MMMM yyyy)
  String _formatDateIndo(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  // Parse tanggal Indonesia (dd MMMM yyyy) ke DateTime
  DateTime _parseDateIndo(String dateStr) {
    return DateFormat('dd MMMM yyyy', 'id_ID').parse(dateStr);
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

  void _addSession() {
    setState(() {
      sessions.add(SessionData());
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (sessions.isNotEmpty && sessions.last.key.currentContext != null) {
        Scrollable.ensureVisible(
          sessions.last.key.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
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

  void _sortSessions() {
    sessions.sort((a, b) {
      final dateA = a.dateController.text.isNotEmpty
          ? _parseDateIndo(a.dateController.text)
          : DateTime(2100);
      final dateB = b.dateController.text.isNotEmpty
          ? _parseDateIndo(b.dateController.text)
          : DateTime(2100);

      final dateComp = dateA.compareTo(dateB);
      if (dateComp != 0) return dateComp;

      final timeA = a.startTimeController.text.isNotEmpty
          ? a.startTimeController.text
          : "23:59";
      final timeB = b.startTimeController.text.isNotEmpty
          ? b.startTimeController.text
          : "23:59";

      return timeA.compareTo(timeB);
    });
  }

  int? _getHariKe(String sessionDateStr) {
    if (startController.text.isEmpty || sessionDateStr.isEmpty) return null;
    try {
      final start = _parseDateIndo(startController.text);
      final current = _parseDateIndo(sessionDateStr);
      final diff = current.difference(start).inDays;
      if (diff >= 0) return diff + 1;
    } catch (_) {}
    return null;
  }

  Future<void> _generateSessions() async {
    if (startController.text.isEmpty || endController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih Tanggal Mulai dan Selesai terlebih dahulu!"),
        ),
      );
      return;
    }

    DateTime startDate = _parseDateIndo(startController.text);
    DateTime endDate = _parseDateIndo(endController.text);

    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tanggal Selesai tidak boleh sebelum Tanggal Mulai!"),
        ),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Lengkapi Sesi"),
        content: const Text(
          "Semua sesi yang sudah ada akan dihapus dan diganti dengan sesi baru. Lanjutkan?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya, Lengkapi"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final diff = endDate.difference(startDate).inDays;

    setState(() {
      for (var s in sessions) {
        s.dispose();
      }
      sessions.clear();

      for (int i = 0; i <= diff; i++) {
        final date = startDate.add(Duration(days: i));
        final s = SessionData();
        s.dateController.text = _formatDateIndo(date);
        sessions.add(s);
      }
      _sortSessions();
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
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      controller.text = _formatDateIndo(picked);
      setState(() {});
    }
  }

  // tanggal selesai - tidak bisa sebelum tanggal mulai
  Future<void> _selectEndDate(BuildContext context) async {
    if (startController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan pilih Tanggal Mulai terlebih dahulu!"),
        ),
      );
      return;
    }

    DateTime startDate = _parseDateIndo(startController.text);
    DateTime initialDate = startDate;
    if (endController.text.isNotEmpty) {
      initialDate = _parseDateIndo(endController.text);
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: startDate,
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      endController.text = _formatDateIndo(picked);
      setState(() {});
    }
  }

  // validasi tanggal sesi
  Future<void> _selectSessionsDate(
    BuildContext context,
    SessionData session,
  ) async {
    if (startController.text.isEmpty || endController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Silakan pilih Tanggal Mulai dan Tanggal Selesai terlebih dahulu!",
          ),
        ),
      );
      return;
    }

    DateTime firstAllowed = _parseDateIndo(startController.text);
    DateTime lastAllowed = _parseDateIndo(endController.text);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstAllowed,
      firstDate: firstAllowed,
      lastDate: lastAllowed,
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      session.dateController.text = _formatDateIndo(picked);
      _sortSessions();
      setState(() {});
      Future.delayed(const Duration(milliseconds: 100), () {
        if (session.key.currentContext != null) {
          Scrollable.ensureVisible(
            session.key.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  // pilih waktu mulai sesi
  Future<void> _selectStartTime(
    BuildContext context,
    SessionData session, {
    int? sessionIndex,
  }) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: session.startTimeController.text.isNotEmpty
          ? TimeOfDay(
              hour: int.parse(session.startTimeController.text.split(':')[0]),
              minute: int.parse(session.startTimeController.text.split(':')[1]),
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
      session.startTimeController.text = _formatTime24(picked);

      // Cek konflik jika end time sudah diisi
      if (sessionIndex != null) {
        final conflict = _getTimeConflict(sessionIndex);
        if (conflict != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Waktu bertabrakan dengan $conflict!")),
          );
        }
      }

      _sortSessions();
      setState(() {});

      Future.delayed(const Duration(milliseconds: 100), () {
        if (session.key.currentContext != null) {
          Scrollable.ensureVisible(
            session.key.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });

      // Jika ini sesi pertama dan ada sesi lain, tanya user
      if (sessionIndex == 0 && sessions.length > 1) {
        await _showDefaultTimeDialog('start', _formatTime24(picked));
      }
    }
  }

  // pilih waktu selesai sesi - tidak bisa sebelum waktu mulai
  Future<void> _selectEndTime(
    BuildContext context,
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

      controller.text = _formatTime24(picked);

      // Cek konflik dengan sesi lain
      if (sessionIndex != null) {
        final conflict = _getTimeConflict(sessionIndex);
        if (conflict != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Waktu bertabrakan dengan $conflict!")),
          );
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

  bool _hasConflictingSessions({bool ignoreExactMatches = false}) {
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
          if (ignoreExactMatches && firstStart.isAtSameMomentAs(secondStart)) {
            continue;
          }
          return true;
        }
      }
    }
    return false;
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

  Future<bool> _showDuplicateSessionsDialog(
    List<Map<String, dynamic>> duplicates,
  ) async {
    return await showDialog<bool>(
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
                  const Expanded(
                    child: Text(
                      "Waktu Sama",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                    "Terdapat beberapa sesi dengan tanggal dan jam mulai yang sama persis:",
                    style: TextStyle(color: AppColor.textSecondary(context)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Column(
                        children: duplicates.map((d) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sesi ${d['index'] + 1} (Hari Ke - ${d['hariKe'] ?? '-'})",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${d['tanggal']} • ${d['jam']}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Apakah Anda yakin tetap ingin menyimpan program ini?",
                    style: TextStyle(color: AppColor.textSecondary(context)),
                  ),
                ],
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
                    backgroundColor: Colors.orange,
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
        ) ??
        false;
  }

  // save data program dan session
  Future<void> _submitAndExit() async {
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
                Icon(Icons.info_outline_rounded, color: Colors.red, size: 28),
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
                  style: TextStyle(color: AppColor.textSecondary(context)),
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

    // Cek duplikat sesi berdasarkan tanggal dan jam yang sama
    List<Map<String, dynamic>> duplicateSessions = [];
    for (int i = 0; i < sessions.length; i++) {
      for (int j = i + 1; j < sessions.length; j++) {
        if (sessions[i].dateController.text.isNotEmpty &&
            sessions[i].startTimeController.text.isNotEmpty &&
            sessions[i].dateController.text ==
                sessions[j].dateController.text &&
            sessions[i].startTimeController.text ==
                sessions[j].startTimeController.text) {
          bool alreadyAddedI = duplicateSessions.any((d) => d['index'] == i);
          if (!alreadyAddedI) {
            duplicateSessions.add({
              'index': i,
              'hariKe': _getHariKe(sessions[i].dateController.text),
              'tanggal': sessions[i].dateController.text,
              'jam': sessions[i].startTimeController.text,
            });
          }

          bool alreadyAddedJ = duplicateSessions.any((d) => d['index'] == j);
          if (!alreadyAddedJ) {
            duplicateSessions.add({
              'index': j,
              'hariKe': _getHariKe(sessions[j].dateController.text),
              'tanggal': sessions[j].dateController.text,
              'jam': sessions[j].startTimeController.text,
            });
          }
        }
      }
    }

    if (duplicateSessions.isNotEmpty) {
      duplicateSessions.sort(
        (a, b) => (a['index'] as int).compareTo(b['index'] as int),
      );
      final confirmed = await _showDuplicateSessionsDialog(duplicateSessions);
      if (!confirmed) return;
    }

    if (_hasConflictingSessions(ignoreExactMatches: true)) {
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

    // ambil user id yang sedang login dari Firebase
    String? userId = FirebaseService.getCurrentUid();
    if (userId == null) return;

    // insert program ke Firestore
    String programId = await FirebaseService.insertProgram({
      "userId": userId,
      "subject": subjectController.text,
      "startDate": _indoToIso(startController.text),
      "endDate": _indoToIso(endController.text),
      "description": deskController.text,
    });

    // insert session ke Firestore
    for (var s in sessions) {
      SessionModel session = SessionModel(
        programId: programId,
        topic: s.topicController.text,
        date: _indoToIso(s.dateController.text),
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
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
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
            "Data program yang sedang dibuat belum disimpan dan akan hilang. Apakah Anda yakin ingin keluar?",
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColor.gradien2,
          onPressed: _addSession,
          child: const Icon(Icons.add, color: Colors.white),
        ),
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
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () async {
                      final shouldExit = await _showExitConfirmDialog();
                      if (shouldExit && mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
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
                          hintStyle: TextStyle(
                            color: AppColor.textHint(context),
                          ),
                          filled: true,
                          fillColor: AppColor.inputFill(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "Tanggal Mulai",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 7),
                      TextFormField(
                        controller: startController,
                        readOnly: true,
                        onTap: () => _selectDate(context, startController),
                        style: TextStyle(color: AppColor.textPrimary(context)),
                        decoration: InputDecoration(
                          hintText: "Mulai",
                          hintStyle: TextStyle(
                            color: AppColor.textHint(context),
                          ),
                          filled: true,
                          fillColor: AppColor.inputFill(context),
                          prefixIcon: Icon(
                            Icons.calendar_month,
                            color: AppColor.iconColor(context),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "Tanggal Selesai",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 7),
                      TextFormField(
                        controller: endController,
                        readOnly: true,
                        onTap: () => _selectEndDate(context),
                        style: TextStyle(color: AppColor.textPrimary(context)),
                        decoration: InputDecoration(
                          hintText: "Selesai",
                          hintStyle: TextStyle(
                            color: AppColor.textHint(context),
                          ),
                          filled: true,
                          fillColor: AppColor.inputFill(context),
                          prefixIcon: Icon(
                            Icons.calendar_month,
                            color: AppColor.iconColor(context),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
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
                          hintStyle: TextStyle(
                            color: AppColor.textHint(context),
                          ),
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
                    ElevatedButton.icon(
                      onPressed: _generateSessions,
                      icon: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        "Lengkapi",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.gradien2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Column(
                  children: List.generate(sessions.length, (index) {
                    final session = sessions[index];
                    final hariKe = _getHariKe(session.dateController.text);
                    Widget? header;
                    if (hariKe != null) {
                      if (index == 0 ||
                          _getHariKe(sessions[index - 1].dateController.text) !=
                              hariKe) {
                        header = Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            bottom: 8,
                            top: 8,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Hari Ke - $hariKe",
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (header != null) header,
                        Container(
                          key: session.key,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                style: TextStyle(
                                  color: AppColor.textPrimary(context),
                                ),
                                decoration: InputDecoration(
                                  hintText: "Masukkan topik materi",
                                  hintStyle: TextStyle(
                                    color: AppColor.textHint(context),
                                  ),
                                  filled: true,
                                  fillColor: AppColor.inputFill(context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),
                              Text(
                                "Tanggal",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.textPrimary(context),
                                ),
                              ),

                              const SizedBox(height: 10),
                              TextFormField(
                                controller: session.dateController,
                                readOnly: true,
                                onTap: () =>
                                    _selectSessionsDate(context, session),
                                style: TextStyle(
                                  color: AppColor.textPrimary(context),
                                ),
                                decoration: InputDecoration(
                                  hintText: "Pilih Tanggal",
                                  hintStyle: TextStyle(
                                    color: AppColor.textHint(context),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
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

                              Text(
                                "Waktu",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.textPrimary(context),
                                ),
                              ),

                              const SizedBox(height: 7),

                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: session.startTimeController,
                                      readOnly: true,
                                      onTap: () => _selectStartTime(
                                        context,
                                        session,
                                        sessionIndex: index,
                                      ),
                                      style: TextStyle(
                                        color: AppColor.textPrimary(context),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Mulai",
                                        hintStyle: TextStyle(
                                          color: AppColor.textHint(context),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.access_time,
                                          color: AppColor.iconColor(context),
                                        ),
                                        filled: true,
                                        fillColor: AppColor.inputFill(context),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                      onTap: () => _selectEndTime(
                                        context,
                                        session.endTimeController,
                                        session.startTimeController,
                                        sessionIndex: index,
                                      ),
                                      style: TextStyle(
                                        color: AppColor.textPrimary(context),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Selesai",
                                        hintStyle: TextStyle(
                                          color: AppColor.textHint(context),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.access_time,
                                          color: AppColor.iconColor(context),
                                        ),
                                        filled: true,
                                        fillColor: AppColor.inputFill(context),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
      ),
    );
  }
}

class SessionData {
  final GlobalKey key = GlobalKey();
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
