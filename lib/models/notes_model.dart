import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class NotesModel {
  final int? id;
  final String title;
  final String content;
  final String date;
  NotesModel({
    this.id,
    required this.title,
    required this.content,
    required this.date,
  });


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'content': content,
      'date': date,
    };
  }

  factory NotesModel.fromMap(Map<String, dynamic> map) {
    return NotesModel(
      id: map['id'] != null ? map['id'] as int : null,
      title: map['title'] as String,
      content: map['content'] as String,
      date: map['date'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotesModel.fromJson(String source) =>
      NotesModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
