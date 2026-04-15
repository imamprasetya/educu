import 'package:educu_project/view/programs/delete_program.dart';
import 'package:educu_project/view/programs/edit_program.dart';
import 'package:educu_project/view/programs/program_detail.dart';
import 'package:flutter/material.dart';
import 'package:educu_project/constant/app_color.dart';

import '../../services/firebase_service.dart';
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

  String? userId;

  @override
  void initState() {
    super.initState();
    getUser();
    searchFocus.addListener(() {
      setState(() {
        isFocused = searchFocus.hasFocus;
      });
    });
  }

  // mengambil user yang sedang login
  Future<void> getUser() async {
    userId = FirebaseService.getCurrentUid();
    loadPrograms();
  }

  // load program berdasarkan user
  Future<void> loadPrograms() async {
    if (userId == null) return;

    final result = await FirebaseService.getProgramsByUser(userId!);

    setState(() {
      programs = result;
      filteredPrograms = result;
    });
  }

  // search program
  void searchProgram(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        filteredPrograms = programs;
      });
      return;
    }

    final results = programs.where((program) {
      final subject = program.subject.toLowerCase();
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
              // search
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

              // progress card
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

              // list program
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
                                  items.subject,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditProgram(program: items),
                                          ),
                                        );
                                        loadPrograms();
                                      },
                                    ),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        await showDeleteDialog(
                                          context,
                                          items.id!,
                                        );
                                        loadPrograms();
                                      },
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
                                  children: [
                                    Text(
                                      "Progress",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    Text(
                                      "50%",
                                      style: TextStyle(
                                        color: AppColor.gradien2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: const LinearProgressIndicator(
                                    value: 0.5,
                                    minHeight: 8,
                                    backgroundColor: Color(0xFFDBD8FF),
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.blueAccent,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                    ),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProgramDetail(program: items),
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
