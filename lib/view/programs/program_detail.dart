import 'package:educu_project/constant/app_color.dart';
import 'package:flutter/material.dart';

class ProgramDetail extends StatefulWidget {
  const ProgramDetail({super.key});

  @override
  State<ProgramDetail> createState() => _ProgramDetailState();
}

class _ProgramDetailState extends State<ProgramDetail> {
  List<String> images = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
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
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 25),
                  ),
                  SizedBox(width: 15),
                  Text(
                    "Pelajaran",
                    style: TextStyle(
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
              Container(
                padding: EdgeInsets.all(16),
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
                        Text(
                          "Description",
                          style: TextStyle(color: Colors.black54),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Complete mathematics fundamentals course covering all basic topics",
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Timeline",
                              style: TextStyle(color: Colors.black54),
                            ),
                            SizedBox(height: 3),
                            Text("15 September 2026 - 15 December 2026"),
                          ],
                        ),
                        Column(
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
                        Row(
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
                        SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
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
              SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    "Daily Sessions",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColor.box1,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey,
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_sharp,
                          color: AppColor.gradien1,
                        ),
                        SizedBox(width: 7),
                        Text(
                          "Session 1",
                          style: TextStyle(color: AppColor.gradien1),
                        ),
                      ],
                    ),
                    Text("Monday, 15 September 2026"),
                    Text(
                      "Perkalian",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Session Notes",
                          style: TextStyle(color: Colors.black54),
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          //isi dari notes nya diambil data dari pomodoro timer
                          maxLines: 2,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: "Notes...",
                            filled: true,
                            fillColor: const Color.fromARGB(255, 235, 234, 248),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              SizedBox(height: 20),

              Row(
                children: [
                  Text(
                    "Final Project",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),

              SizedBox(height: 15),

              Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.box1,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey,
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload Image Section
                    Row(
                      children: [
                        Icon(Icons.image, color: AppColor.gradien1),
                        SizedBox(width: 8),
                        Text(
                          "Upload Project Images",
                          style: TextStyle(color: AppColor.gradien1),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 235, 234, 248),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.add_a_photo),
                            onPressed: () {
                              // nanti bisa pakai image picker
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Notes
                    Text(
                      "Project Notes",
                      style: TextStyle(color: Colors.black54),
                    ),

                    SizedBox(height: 5),

                    TextFormField(
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: "Write your project notes...",
                        filled: true,
                        fillColor: const Color.fromARGB(255, 235, 234, 248),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // COMPLETE PROGRAM BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.gradien1,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          // aksi ketika program selesai
                        },
                        child: Text(
                          "COMPLETE PROGRAM",
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
            ],
          ),
        ),
      ),
    );
  }
}
