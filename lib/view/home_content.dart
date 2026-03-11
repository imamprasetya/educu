import 'package:flutter/material.dart';
import '../constant/app_color.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F6),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white30,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back",
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "Imam",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 15),

                  Text(
                    "Good afternoon Imam 👋",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "Ready to study today?",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// MOTIVATION CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.gradien2, AppColor.gradien1],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "Study a little every day for big results.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// INDICATOR DOT
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [dot(true), dot(false), dot(false), dot(false)],
            ),

            const SizedBox(height: 20),

            /// STUDY PROGRESS CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Study Progress",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  /// CHART PLACEHOLDER
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text("Chart Progress")),
                  ),

                  const SizedBox(height: 15),

                  /// STATS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.local_fire_department, color: Colors.red),
                          SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Streak"),
                              Text(
                                "7 days",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        children: const [
                          Icon(Icons.access_time, color: Colors.blue),
                          SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total Time"),
                              Text(
                                "24 hours",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// TODAY SCHEDULE TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Today's Schedule",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  Text("View all", style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// SCHEDULE CARD
            scheduleCard("Mathematics", "14:00 - 16:00"),
            scheduleCard("Physics", "16:30 - 18:00"),
            scheduleCard("Chemistry", "19:00 - 20:30"),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// DOT INDICATOR
  static Widget dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: active ? 18 : 6,
      decoration: BoxDecoration(
        color: active ? Colors.blue : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  /// SCHEDULE CARD
  static Widget scheduleCard(String subject, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(color: Colors.black54)),
            ],
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {},
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }
}
