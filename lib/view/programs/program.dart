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

  // progress cache per program
  Map<String, double> progressMap = {};

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  bool isFocused = false;
  String? userId;

  // Tab filter
  int selectedTab = 1; // 0=Semua, 1=Active, 2=Terlewat, 3=Selesai
  final List<String> tabLabels = ["Semua", "Active", "Terlewat", "Selesai"];

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

  Future<void> getUser() async {
    userId = FirebaseService.getCurrentUid();
    loadPrograms();
  }

  Future<void> loadPrograms() async {
    if (userId == null) return;

    final result = await FirebaseService.getProgramsByUser(userId!);

    // load progress for each program
    Map<String, double> pMap = {};
    for (var p in result) {
      if (p.id != null) {
        pMap[p.id!] = await FirebaseService.getProgramProgress(p.id!);
      }
    }

    setState(() {
      programs = result;
      progressMap = pMap;
      _applyFilter();
    });
  }

  void _applyFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<ProgramModel> filtered;

    switch (selectedTab) {
      case 1: // Active
        filtered = programs.where((p) {
          final end = DateTime.tryParse(p.endDate);
          final progress = progressMap[p.id] ?? 0;
          return end != null && !end.isBefore(today) && progress < 1.0;
        }).toList();
        break;
      case 2: // Terlewat (end date passed & not 100%)
        filtered = programs.where((p) {
          final end = DateTime.tryParse(p.endDate);
          final progress = progressMap[p.id] ?? 0;
          return end != null && end.isBefore(today) && progress < 1.0;
        }).toList();
        break;
      case 3: // Selesai (100%)
        filtered = programs.where((p) {
          final progress = progressMap[p.id] ?? 0;
          return progress >= 1.0;
        }).toList();
        break;
      default: // Semua
        filtered = List.from(programs);
    }

    // apply search
    final keyword = searchController.text.toLowerCase();
    if (keyword.isNotEmpty) {
      filtered = filtered
          .where((p) => p.subject.toLowerCase().contains(keyword))
          .toList();
    }

    setState(() {
      filteredPrograms = filtered;
    });
  }

  void searchProgram(String keyword) {
    _applyFilter();
  }

  // Overall progress
  double get overallProgress {
    if (programs.isEmpty) return 0;
    double total = 0;
    for (var p in programs) {
      total += (progressMap[p.id] ?? 0);
    }
    return total / programs.length;
  }

  @override
  Widget build(BuildContext context) {
    final overallPct = (overallProgress * 100).toInt();

    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
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
                    "Program Belajar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Pantau progres belajar Anda",
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
                  color: AppColor.searchBox(context),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.shadowColor(context),
                      blurRadius: 2,
                      spreadRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: searchController,
                  focusNode: searchFocus,
                  onChanged: searchProgram,
                  style: TextStyle(color: AppColor.textPrimary(context)),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColor.iconColor(context),
                    ),
                    hintText: "Cari subjek...",
                    hintStyle: TextStyle(color: AppColor.textHint(context)),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // overall progress card
              Container(
                padding: const EdgeInsets.all(16),
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.isDark(context)
                      ? Colors.blue.withValues(alpha: 0.15)
                      : Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Program",
                          style: TextStyle(
                            color: AppColor.textPrimary(context),
                          ),
                        ),
                        Text(
                          "Progres Keseluruhan",
                          style: TextStyle(
                            color: AppColor.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          programs.length.toString(),
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textPrimary(context),
                          ),
                        ),
                        Text(
                          "$overallPct%",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: overallProgress,
                        minHeight: 8,
                        backgroundColor: AppColor.isDark(context)
                            ? Colors.grey.shade800
                            : const Color(0xFFDBD8FF),
                        valueColor: const AlwaysStoppedAnimation(
                          Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // TAB FILTER
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabLabels.length,
                  itemBuilder: (context, index) {
                    final isActive = selectedTab == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          tabLabels[index],
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : AppColor.textPrimary(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: isActive,
                        selectedColor: AppColor.gradien2,
                        backgroundColor: AppColor.isDark(context)
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        onSelected: (val) {
                          setState(() {
                            selectedTab = index;
                            _applyFilter();
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              // list program
              filteredPrograms.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        "Program tidak ditemukan",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.textHint(context),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPrograms.length,
                      itemBuilder: (context, index) {
                        final items = filteredPrograms[index];
                        final prog = progressMap[items.id] ?? 0;
                        final pct = (prog * 100).toInt();

                        return Card(
                          elevation: 3,
                          color: AppColor.cardColor(context),
                          shadowColor: AppColor.shadowColor(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        items.subject,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColor.textPrimary(context),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                            size: 20,
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
                                            size: 20,
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

                                Text(
                                  "${items.startDate} - ${items.endDate}",
                                  style: TextStyle(
                                    color: AppColor.textHint(context),
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Progres",
                                      style: TextStyle(
                                        color: AppColor.textSecondary(context),
                                      ),
                                    ),
                                    Text(
                                      "$pct%",
                                      style: TextStyle(
                                        color: prog >= 1.0
                                            ? Colors.green
                                            : AppColor.gradien2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 5),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: prog,
                                    minHeight: 8,
                                    backgroundColor: AppColor.isDark(context)
                                        ? Colors.grey.shade800
                                        : const Color(0xFFDBD8FF),
                                    valueColor: AlwaysStoppedAnimation(
                                      prog >= 1.0
                                          ? Colors.green
                                          : Colors.blueAccent,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProgramDetail(program: items),
                                        ),
                                      );
                                      loadPrograms();
                                    },
                                    child: const Text(
                                      "Lihat Detail",
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
