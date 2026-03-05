import 'package:flutter/material.dart';
import '../models/program_model.dart';

class TambahProgramScreen extends StatefulWidget {
  const TambahProgramScreen({super.key});

  @override
  State<TambahProgramScreen> createState() => _TambahProgramScreenState();
}

class _TambahProgramScreenState extends State<TambahProgramScreen> {
  TextEditingController nama = TextEditingController();

  List<JadwalBelajar> daftarJadwal = [];

  void tambahJadwal() {
    TextEditingController materi = TextEditingController();
    TextEditingController jam = TextEditingController();
    TextEditingController youtube = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Jadwal"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: materi,
                decoration: const InputDecoration(labelText: "Materi"),
              ),

              TextField(
                controller: jam,
                decoration: const InputDecoration(
                  labelText: "Jam (14:00-16:00)",
                ),
              ),

              TextField(
                controller: youtube,
                decoration: const InputDecoration(labelText: "Link Youtube"),
              ),
            ],
          ),

          actions: [
            ElevatedButton(
              child: const Text("Submit"),

              onPressed: () {
                daftarJadwal.add(
                  JadwalBelajar(
                    namaProgram: nama.text,
                    materi: materi.text,
                    tanggal: DateTime.now(),
                    jamMulai: jam.text.split("-")[0],
                    jamSelesai: jam.text.split("-")[1],
                    youtube: youtube.text,
                  ),
                );

                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Program")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nama,
              decoration: const InputDecoration(labelText: "Nama Program"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: tambahJadwal,
              child: const Text("Tambah Detail Jadwal"),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: daftarJadwal.length,
                itemBuilder: (context, index) {
                  final j = daftarJadwal[index];

                  return ListTile(
                    title: Text(j.materi),
                    subtitle: Text("${j.jamMulai}-${j.jamSelesai}"),
                  );
                },
              ),
            ),

            ElevatedButton(
              child: const Text("Simpan Program"),

              onPressed: () {
                final program = Program(
                  namaProgram: nama.text,
                  mulai: DateTime.now(),
                  selesai: DateTime.now(),
                  jadwal: daftarJadwal,
                );

                Navigator.pop(context, program);
              },
            ),
          ],
        ),
      ),
    );
  }
}
