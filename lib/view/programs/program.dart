import 'package:flutter/material.dart';
import 'package:educu_project/constant/app_color.dart';
import '../../database/sqflite.dart';
import 'add_program.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  List<Map<String, dynamic>> programs = [];

  @override
  void initState() {
    super.initState();
    loadPrograms();
  }

  /// LOAD DATA PROGRAM DARI DATABASE
  Future<void> loadPrograms() async {
    final data = await DBHelper.getPrograms();

    setState(() {
      programs = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: programs.isEmpty
          /// JIKA BELUM ADA PROGRAM
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Tidak ada Program",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Silakan tambah program belajar",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          /// JIKA ADA PROGRAM
          : ListView.builder(
              itemCount: programs.length,
              itemBuilder: (context, index) {
                final program = programs[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.school, color: Colors.blue),
                    title: Text(
                      program["subject"] ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${program["startDate"]} - ${program["endDate"]}",
                    ),
                  ),
                );
              },
            ),

      /// BUTTON TAMBAH PROGRAM
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.logo,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProgram()),
          );

          /// REFRESH DATA SETELAH TAMBAH PROGRAM
          if (result == true) {
            loadPrograms();
          }
        },
      ),
    );
  }
}
