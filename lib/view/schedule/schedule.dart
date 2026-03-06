import 'package:educu_project/view/schedule/pomodoro.dart';
import 'package:flutter/material.dart';
import '../../models/program_model.dart';
import '../programs/program.dart';
import 'pomodoro.dart';

class JadwalScreen extends StatelessWidget {
  const JadwalScreen({super.key});

  List<JadwalBelajar> ambilJadwal() {
    List<JadwalBelajar> semua = [];

    for (var p in ProgramScreen.programs) {
      semua.addAll(p.jadwal);
    }

    return semua;
  }

  @override
  Widget build(BuildContext context) {
    final jadwal = ambilJadwal();

    if (jadwal.isEmpty) {
      return const Center(child: Text("Tidak Ada Jadwal"));
    }

    return ListView.builder(
      itemCount: jadwal.length,
      itemBuilder: (context, index) {
        final j = jadwal[index];

        return Card(
          margin: const EdgeInsets.all(12),
          child: ListTile(
            title: Text(j.namaProgram),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(j.materi), Text("${j.jamMulai}-${j.jamSelesai}")],
            ),

            trailing: Icon(
              j.selesai ? Icons.check_circle : Icons.circle_outlined,
              color: j.selesai ? Colors.green : Colors.grey,
            ),

            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(j.namaProgram),

                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(j.materi),

                        Text("${j.jamMulai}-${j.jamSelesai}"),

                        const SizedBox(height: 10),

                        Image.network(
                          "https://img.youtube.com/vi/${extractId(j.youtube)}/0.jpg",
                        ),
                      ],
                    ),

                    actions: [
                      ElevatedButton(
                        child: const Text("Mulai Belajar"),

                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PomodoroScreen(jadwal: j),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String extractId(String url) {
    if (url.contains("v=")) {
      return url.split("v=")[1];
    }

    return "";
  }
}
