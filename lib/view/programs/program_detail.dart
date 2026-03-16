import 'package:educu_project/constant/app_color.dart';
import 'package:flutter/material.dart';
import '../../models/program_model.dart';

class ProgramDetail extends StatefulWidget {
  final ProgramModel program;

  const ProgramDetail({super.key, required this.program});

  @override
  State<ProgramDetail> createState() => _ProgramDetailState();
}

class _ProgramDetailState extends State<ProgramDetail> {
  List<String> images = [];

  @override
  Widget build(BuildContext context) {
    final program = widget.program;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.gradien2, AppColor.gradien1],
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    program.subject ?? "Program Detail",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: Column(
            children: [
              // program info
              Container(
                padding: const EdgeInsets.all(16),
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.blue),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description",
                          style: TextStyle(color: Colors.black54),
                        ),

                        const SizedBox(height: 3),

                        Text(program.description ?? "-"),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              "Timeline",
                              style: TextStyle(color: Colors.black54),
                            ),

                            const SizedBox(height: 3),

                            Text("${program.startDate} - ${program.endDate}"),
                          ],
                        ),

                        const Column(
                          children: [
                            Text(
                              "Duration",
                              style: TextStyle(color: Colors.black54),
                            ),
                            SizedBox(height: 3),
                            Text("90 days"),
                          ],
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Progress",
                              style: TextStyle(color: Colors.black54),
                            ),
                            Text(
                              "65%",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: const LinearProgressIndicator(
                            value: 0.65,
                            minHeight: 8,
                            backgroundColor: Color(0xFFDBD8FF),
                            valueColor: AlwaysStoppedAnimation(
                              Colors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              const Row(
                children: [
                  Text(
                    "Daily Sessions",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColor.box1,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.blueGrey,
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),

                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Session list akan muncul dari database nanti"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
