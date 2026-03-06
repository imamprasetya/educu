import 'package:educu_project/constant/app_color.dart';
import 'package:flutter/material.dart';
import '../../models/program_model.dart';
import 'add_program.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  static List<Program> programs = [];

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Program Belajar")),
      // body: Padding(
      //   padding: const EdgeInsets.all(12),
      //   child: Column(
      //     children: [
      //       Stack(
      //         children: [
      //           Container(
      //             height: 120,
      //             width: double.infinity,
      //             padding: EdgeInsets.all(16),
      //             decoration: BoxDecoration(
      //               gradient: LinearGradient(
      //                 colors: [
      //                   const Color.fromARGB(255, 56, 113, 139),
      //                   AppColor.logo,
      //                 ],
      //                 begin: Alignment.topLeft,
      //                 end: Alignment.bottomRight,
      //               ),
      //               borderRadius: BorderRadius.circular(15),
      //             ),
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               Text(
      //                 "Overall Progress",
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontWeight: FontWeight.bold,
      //                   fontSize: 18,
      //                 ),
      //               ),
      //               Text(
      //                 "60%",
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 20,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //             ],
      //           ),

      //           //progress bar
      //           LinearProgressIndicator(
      //             value: 0.6,
      //             backgroundColor: Colors.white,
      //             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      //           ),

      //           Row(
      //             children: [
      //               Text(
      //                 "2 active programs",
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),

      // ProgramScreen.programs.isEmpty
      //     ? const Center(child: Text("Belum Ada Program"))
      //     : ListView.builder(
      //         itemCount: ProgramScreen.programs.length,
      //         itemBuilder: (context, index) {
      //           final program = ProgramScreen.programs[index];

      //           return Card(
      //             margin: const EdgeInsets.all(16),
      //             child: ListTile(
      //               title: Text(program.namaProgram),

      //               subtitle: Text(
      //                 "${program.mulai.day}/${program.mulai.month}/${program.mulai.year} - "
      //                 "${program.selesai.day}/${program.selesai.month}/${program.selesai.year}",
      //               ),

      //               trailing: PopupMenuButton(
      //                 itemBuilder: (context) => [
      //                   const PopupMenuItem(
      //                     value: "edit",
      //                     child: Text("Edit"),
      //                   ),
      //                   const PopupMenuItem(
      //                     value: "hapus",
      //                     child: Text("Hapus"),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           );
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () async {
          final programBaru = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProgram()),
          );

          if (programBaru != null) {
            setState(() {
              ProgramScreen.programs.add(programBaru);
            });
          }
        },
      ),
    );
  }
}
