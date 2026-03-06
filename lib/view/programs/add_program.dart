import 'package:educu_project/constant/app_color.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController topicController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  //Fungsi Tanggal
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
      setState(() {
        controller.text = picked.toString().split(' ')[0];
      });
    }
  }

  //Fungsi Jam
  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Tambah Program Belajar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.logo,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            //Subject Name
                            Row(
                              children: [
                                Text(
                                  "Subject Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 7),
                            TextFormField(
                              controller: subjectController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10),
                                filled: true,
                                fillColor: Colors.grey[200],
                                hintText: "Enter subject name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),

                            SizedBox(height: 15),

                            //Tanggal
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Start Date",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 7),
                                      TextFormField(
                                        controller: startController,
                                        readOnly: true,
                                        onTap: () => _selectDate(
                                          context,
                                          startController,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                          hintText: "Select Date",
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                            size: 18,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "End Date",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 7),
                                      TextFormField(
                                        controller: endController,
                                        readOnly: true,
                                        onTap: () =>
                                            _selectDate(context, endController),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                          hintText: "Select Date",
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                            size: 18,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),

                            //Description
                            Row(
                              children: [
                                Text(
                                  "Short Description",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 7),
                            TextFormField(
                              controller: deskController,
                              maxLines: 5,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10),
                                filled: true,
                                fillColor: Colors.grey[200],
                                hintText: "Enter program description",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  //Session
                  Row(
                    children: [
                      Text(
                        "Sessions",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      // FloatingActionButton(onPressed: )
                    ],
                  ),
                  SizedBox(height: 10),

                  // Sessions Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Day 1",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Material Topic
                        const Text(
                          "Material Topic",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 7),
                        TextFormField(
                          controller: topicController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            filled: true,
                            fillColor: Colors.grey[200],
                            hintText: "Enter Topic",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Date and Time Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //DATE
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Date",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  TextFormField(
                                    controller: dateController,
                                    readOnly: true,
                                    onTap: () =>
                                        _selectDate(context, dateController),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(10),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      hintText: "Select Date",
                                      prefixIcon: const Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            //TIME
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Time",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  TextFormField(
                                    controller: timeController,
                                    readOnly: true,
                                    onTap: () =>
                                        _selectTime(context, timeController),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(10),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      hintText: "Select Time",
                                      prefixIcon: const Icon(
                                        Icons.access_time,
                                        size: 18,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  //Button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
