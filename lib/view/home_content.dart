import 'dart:async';
import 'dart:convert';
import 'package:educu_project/models/user_model.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/view/schedule/pomodoro.dart';
import 'package:flutter/material.dart';
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
    "Study a little every day for big results.",
    "Small progress is still progress.",
    "Consistency beats motivation.",
    "Your future is created by what you do today.",
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
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    if (hour < 21) return "Good evening";
    return "Good night";
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
                  colors: [AppColor.gradien1, AppColor.gradien2],
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
                            "Welcome back",
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
                    "Ready to study today?",
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
                  colors: [AppColor.gradien2, AppColor.gradien1],
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
                    "Study Progress",
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
                        "Programs",
                        isLoading ? "..." : totalPrograms.toString(),
                      ),
                      _statItem(
                        Icons.calendar_today,
                        Colors.orange,
                        "Sessions",
                        isLoading ? "..." : totalSessions.toString(),
                      ),
                      _statItem(
                        Icons.today,
                        Colors.green,
                        "Today",
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
                    "Today's Schedule",
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
                  "No schedule today 📚",
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

  // schedule card (from Firebase data)
  Widget scheduleCard(
    String subject,
    String topic,
    String time,
    Map<String, dynamic> data,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(18),
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
              color: AppColor.gradien2,
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
                    color: AppColor.textPrimary(context),
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

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PomodoroScreen(
                    subject: subject,
                    topic: topic,
                    sessionId: data["id"],
                  ),
                ),
              );
            },
            child: const Text("Start", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
