import 'dart:async';
import 'package:flutter/material.dart';
import '../constant/app_color.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController();
  int currentPage = 0;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F6),

      body: SingleChildScrollView(
        child: Column(
          children: [
<<<<<<< HEAD
=======
            // header
>>>>>>> 0520a2b859a19dbaba28f1d9c0ea10fa11c7e78e
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

<<<<<<< HEAD
            // MOTIVATION CARD
=======
            // motivation card
>>>>>>> 0520a2b859a19dbaba28f1d9c0ea10fa11c7e78e
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

<<<<<<< HEAD
            // INDICATOR DOT
=======
            // indicator dot
>>>>>>> 0520a2b859a19dbaba28f1d9c0ea10fa11c7e78e
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                quotes.length,
                (index) => dot(index == currentPage),
              ),
            ),

            const SizedBox(height: 20),

<<<<<<< HEAD
            // STUDY PROGRESS CARD
=======
            // study progress card
>>>>>>> 0520a2b859a19dbaba28f1d9c0ea10fa11c7e78e
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

<<<<<<< HEAD
                  // CHART PLACEHOLDER
=======
                  // chart placeholder
>>>>>>> 0520a2b859a19dbaba28f1d9c0ea10fa11c7e78e
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text("Chart Progress")),
                  ),

                  const SizedBox(height: 15),

<<<<<<< HEAD
                  // STATS
=======
                  // stats
>>>>>>> 0520a2b859a19dbaba28f1d9c0ea10fa11c7e78e
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

<<<<<<< HEAD
            // TODAY SCHEDULE TITLE
=======
            // today schedule title
>>>>>>> 0520a2b859a19dbaba28f1d9c0ea10fa11c7e78e
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

<<<<<<< HEAD
            // SCHEDULE CARD
            scheduleCard("App Developer", "14:00 - 16:00"),
            scheduleCard("Web Developer", "16:30 - 18:00"),
            scheduleCard("Cyber Scurity", "19:00 - 20:30"),
=======
            // schedule card
            scheduleCard("Mathematics", "14:00 - 16:00"),
            scheduleCard("Physics", "16:30 - 18:00"),
            scheduleCard("Chemistry", "19:00 - 20:30"),
>>>>>>> 0520a2b859a19dbaba28f1d9c0ea10fa11c7e78e

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  // DOT INDICATOR
=======
  // dot indicator
>>>>>>> 0520a2b859a19dbaba28f1d9c0ea10fa11c7e78e
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

<<<<<<< HEAD
  // SCHEDULE CARD
=======
  // schedule card
>>>>>>> 0520a2b859a19dbaba28f1d9c0ea10fa11c7e78e
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
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {},
            child: const Text("Start", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
