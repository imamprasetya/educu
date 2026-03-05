class JadwalBelajar {
  String namaProgram;
  String materi;
  DateTime tanggal;
  String jamMulai;
  String jamSelesai;
  String youtube;
  bool selesai;

  JadwalBelajar({
    required this.namaProgram,
    required this.materi,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.youtube,
    this.selesai = false,
  });
}

class Program {
  String namaProgram;
  DateTime mulai;
  DateTime selesai;
  List<JadwalBelajar> jadwal;

  Program({
    required this.namaProgram,
    required this.mulai,
    required this.selesai,
    required this.jadwal,
  });
}
