import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SiswaModel {
  final int? id;
  final String nama;
  final String kelas;
  SiswaModel({this.id, required this.nama, required this.kelas});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'nama': nama, 'kelas': kelas};
  }

  factory SiswaModel.fromMap(Map<String, dynamic> map) {
    return SiswaModel(
      id: map['id'] != null ? map['id'] as int : null,
      nama: map['nama'] as String,
      kelas: map['kelas'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SiswaModel.fromJson(String source) =>
      SiswaModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
