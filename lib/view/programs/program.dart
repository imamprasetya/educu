import 'package:educu_project/view/programs/delete_program.dart';
import 'package:educu_project/view/programs/edit_program.dart';
import 'package:educu_project/view/programs/program_detail.dart';
import 'package:flutter/material.dart';
import 'package:educu_project/constant/app_color.dart';
import '../../database/sqflite.dart';
import '../../models/program_model.dart';
import 'add_program.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  List<ProgramModel> programs = [];
  List<ProgramModel> filteredPrograms = [];

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    loadPrograms();

    searchFocus.addListener(() {
      setState(() {
        isFocused = searchFocus.hasFocus;
      });
    });
  }

  // LOAD DATA PROGRAM DARI DATABASE
  Future<void> loadPrograms() async {
    final data = await DBHelper.getPrograms();
    final result = data.map((e) => ProgramModel.fromMap(e)).toList();

    setState(() {
      programs = result;
      filteredPrograms = result;
    });
  }

  // Search Program
  void searchProgram(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        filteredPrograms = programs;
      });
      return;
    }

    final results = programs.where((program) {
      final subject = program.subject?.toLowerCase() ?? "";
      final input = keyword.toLowerCase();
      return subject.contains(input);
    }).toList();

    setState(() {
      filteredPrograms = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
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
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Learning Programs",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Track your study progress",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: AppColor.box,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.blueGrey,
                      blurRadius: 2,
                      spreadRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: searchController,
                  focusNode: searchFocus,
                  onChanged: searchProgram,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search subject...",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Progress Card
              Container(
                padding: const EdgeInsets.all(16),
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Active Programs"),
                        Text("Overall Progress"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          programs.length.toString(),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "60%",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.6,
                        minHeight: 8,
                        backgroundColor: Color(0xFFDBD8FF),
                        valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // List Program
              filteredPrograms.isEmpty
                  ? const Center(
                      child: Text(
                        "No program found",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPrograms.length,
                      itemBuilder: (context, index) {
                        final items = filteredPrograms[index];

                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  items.subject ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditProgram(program: items),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await showDeleteDialog(
                                          context,
                                          items.id!,
                                        );
                                        await loadPrograms();
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${items.startDate} - ${items.endDate}"),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text("Progress"),
                                    Text(
                                      "75%",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: const LinearProgressIndicator(
                                    value: 0.6,
                                    minHeight: 8,
                                    backgroundColor: Color(0xFFDBD8FF),
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.blueAccent,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProgramDetail(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "View Detail",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),

      // Button Add
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProgram()),
          );

          if (result == true) {
            loadPrograms();
          }
        },
      ),
    );
  }
}
