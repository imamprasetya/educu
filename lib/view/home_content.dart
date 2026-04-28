import 'dart:async';
import 'dart:convert';
import 'package:educu_project/models/user_model.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/view/schedule/pomodoro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../constant/app_color.dart';

class HomeContent extends StatefulWidget {
  final UserModel user;

  const HomeContent({super.key, required this.user});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  // data dari Firebase
  List<Map<String, dynamic>> todaySessions = [];
  int totalPrograms = 0;
  int totalSessions = 0;
  bool isLoading = true;

  final List<String> quotes = [
    "Belajar sedikit setiap hari untuk hasil yang besar.",
    "Kemajuan kecil tetaplah kemajuan.",
    "Konsistensi mengalahkan motivasi.",
    "Masa depanmu diciptakan oleh apa yang kamu lakukan hari ini.",
  ];

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (currentPage < quotes.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }

      _pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );

      setState(() {});
    });

    loadData();
  }

  /// Load data dari Firebase
  Future<void> loadData() async {
    final uid = FirebaseService.getCurrentUid();
    if (uid == null) return;

    // load today's sessions
    final now = DateTime.now();
    final dateStr =
        "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";

    final sessions = await FirebaseService.getSessionsByDate(dateStr);

    // load programs count
    final programs = await FirebaseService.getProgramsByUser(uid);

    // count total sessions across all programs
    int sessionCount = 0;
    for (var program in programs) {
      if (program.id != null) {
        final pSessions = await FirebaseService.getSessions(program.id!);
        sessionCount += pSessions.length;
      }
    }

    if (mounted) {
      setState(() {
        todaySessions = sessions;
        totalPrograms = programs.length;
        totalSessions = sessionCount;
        isLoading = false;
      });
    }
  }

  /// Get greeting berdasarkan waktu
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Selamat pagi";
    if (hour < 15) return "Selamat siang";
    if (hour < 18) return "Selamat sore";
    return "Selamat malam";
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.user.name ?? "User";

    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // header
            Container(
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
                    children: [
                      widget.user.photoBase64 != null
                          ? CircleAvatar(
                              radius: 22,
                              backgroundImage: MemoryImage(
                                base64Decode(widget.user.photoBase64!),
                              ),
                            )
                          : const CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white30,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                      const SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selamat datang kembali",
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "${_getGreeting()}, $userName 👋",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Siap untuk belajar hari ini?",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // motivation card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColor.isDark(context)
                      ? [AppColor.darkCard, AppColor.darkSurface]
                      : [AppColor.gradien2, AppColor.gradien1],
                ),
                borderRadius: BorderRadius.circular(20),
              ),

              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemCount: quotes.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        quotes[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // indicator dot
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                quotes.length,
                (index) => dot(index == currentPage, context),
              ),
            ),

            const SizedBox(height: 20),

            // study progress card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.cardColor(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowColor(context),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Progres Belajar",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColor.textPrimary(context),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem(
                        Icons.menu_book,
                        Colors.blue,
                        "Program",
                        isLoading ? "..." : totalPrograms.toString(),
                      ),
                      _statItem(
                        Icons.calendar_today,
                        Colors.orange,
                        "Sesi",
                        isLoading ? "..." : totalSessions.toString(),
                      ),
                      _statItem(
                        Icons.today,
                        Colors.green,
                        "Hari ini",
                        isLoading ? "..." : todaySessions.length.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // today schedule title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Jadwal Hari Ini",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColor.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // schedule from Firebase
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(30),
                child: CircularProgressIndicator(),
              )
            else if (todaySessions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  "Tidak ada jadwal hari ini 📚",
                  style: TextStyle(
                    color: AppColor.textHint(context),
                    fontSize: 16,
                  ),
                ),
              )
            else
              ...todaySessions.map((session) {
                return scheduleCard(
                  session["subject"] ?? "",
                  session["topic"] ?? "",
                  "${session["startTime"]} - ${session["endTime"]}",
                  session,
                );
              }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // stat item widget
  Widget _statItem(IconData icon, Color color, String label, String value) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColor.textPrimary(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(color: AppColor.textHint(context), fontSize: 12),
        ),
      ],
    );
  }

  // dot indicator
  static Widget dot(bool active, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: active ? 18 : 6,
      decoration: BoxDecoration(
        color: active ? Colors.blue : AppColor.textHint(context),
        borderRadius: BorderRadius.circular(10),
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
              backgroundColor: Colors.blue,
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

  // schedule card (from Firebase data)
  Widget scheduleCard(
    String subject,
    String topic,
    String time,
    Map<String, dynamic> data,
  ) {
    final bool isCompleted = data["completed"] == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(18),
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

      child: Row(
        children: [
          // color indicator
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : AppColor.gradien2,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? AppColor.textHint(context)
                        : AppColor.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topic,
                  style: TextStyle(
                    color: AppColor.textHint(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "Selesai",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PomodoroScreen(
                      subject: subject,
                      topic: topic,
                      sessionId: data["id"],
                      startTime: data["startTime"] ?? "08:00",
                      endTime: data["endTime"] ?? "09:00",
                    ),
                  ),
                );

                if (result == true) {
                  loadData();
                }
              },
              child: const Text("Mulai", style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
