import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/database/sqflite.dart';
import 'package:educu_project/models/session_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          content: Text("Please select Start Date and End Date first!"),
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

  // save data program dan session
  Future<void> _submitAndExit() async {
    // ambil user id yang sedang login
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("userId");

    // insert program ke database
    int programId = await DBHelper.insertProgram({
      "userId": userId,
      "subject": subjectController.text,
      "startDate": startController.text,
      "endDate": endController.text,
      "description": deskController.text,
    });

    // insert session ke database
    for (var s in sessions) {
      SessionModel session = SessionModel(
        programId: programId,
        topic: s.topicController.text,
        date: s.dateController.text,
        startTime: s.startTimeController.text,
        endTime: s.endTimeController.text,
      );

      await DBHelper.insertSession(session);
    }

    // alert berhasil
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: const Text(
            "Program saved successfully!",
            textAlign: TextAlign.center,
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.gradien2, AppColor.gradien1],
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
                  "Add Study Program",
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Subject Name",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 7),

                    TextFormField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        hintText: "Enter subject name",
                        filled: true,
                        fillColor: AppColor.box1,
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
                            decoration: InputDecoration(
                              hintText: "Start Date",
                              filled: true,
                              fillColor: AppColor.box1,
                              suffixIcon: const Icon(Icons.calendar_today),
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
                            decoration: InputDecoration(
                              hintText: "End Date",
                              filled: true,
                              fillColor: AppColor.box1,
                              suffixIcon: const Icon(Icons.calendar_today),
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

                    const Text(
                      "Description",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 7),

                    TextFormField(
                      controller: deskController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Enter program description",
                        filled: true,
                        fillColor: AppColor.box1,
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
                  const Text(
                    "Sessions",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.5),
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
                              "Session ${index + 1}",
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

                        const Text(
                          "Material Topic",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 7),

                        TextFormField(
                          controller: session.topicController,
                          decoration: InputDecoration(
                            hintText: "Enter topic",
                            filled: true,
                            fillColor: AppColor.box1,
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
                          decoration: InputDecoration(
                            hintText: "Select Date",
                            prefixIcon: const Icon(Icons.calendar_today),
                            filled: true,
                            fillColor: AppColor.box1,
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
                                decoration: InputDecoration(
                                  hintText: "Start Time",
                                  prefixIcon: const Icon(Icons.access_time),
                                  filled: true,
                                  fillColor: AppColor.box1,
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
                                decoration: InputDecoration(
                                  hintText: "End Time",
                                  prefixIcon: const Icon(Icons.access_time),
                                  filled: true,
                                  fillColor: AppColor.box1,
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
                    "Save Program",
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
