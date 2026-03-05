import 'package:flutter/material.dart';
import '../models/program_model.dart';

class ProgramDetailScreen extends StatefulWidget {
  final Program program;

  const ProgramDetailScreen({super.key, required this.program});

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    int total = widget.program.jadwal.length;

    int selesai = widget.program.jadwal.where((e) => e.selesai == true).length;

    double progress = total == 0 ? 0 : selesai / total;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff6C63FF), Color(0xff8E7CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      widget.program.namaProgram,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Chip(
                          label: Text(
                            "$total Days Program",
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.white24,
                        ),

                        const SizedBox(width: 10),

                        Chip(
                          label: Text(
                            "${widget.program.mulai.toString().split(" ")[0]} - ${widget.program.selesai.toString().split(" ")[0]}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.white24,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 70,
                              width: 70,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 6,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            ),

                            Text(
                              "${(progress * 100).toInt()}%",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),

                        const SizedBox(width: 20),

                        Text(
                          "$selesai of $total sessions completed",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// DAILY SESSION
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Daily Sessions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.program.jadwal.length,
              itemBuilder: (context, index) {
                final session = widget.program.jadwal[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: session.selesai,
                              onChanged: (value) {
                                setState(() {
                                  session.selesai = value!;
                                });
                              },
                            ),

                            Text(
                              "Day ${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        Text(
                          session.materi,
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text("Notes..."),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            /// FINAL PROJECT
            const Padding(
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Final Project",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Project Photo"),

                    const SizedBox(height: 10),

                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Center(child: Icon(Icons.upload)),
                    ),

                    const SizedBox(height: 20),

                    const Text("Reflection Note"),

                    const SizedBox(height: 10),

                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text("Self-Evaluation"),

                    Row(
                      children: List.generate(
                        5,
                        (index) => IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text("Complete Program"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
