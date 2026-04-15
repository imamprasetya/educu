import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class NotesModel {
  final String? id;
  final String userId;
  final String title;
  final String content;
  final String date;

  NotesModel({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'title': title,
      'content': content,
      'date': date,
    };
  }

  factory NotesModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return NotesModel(
      id: docId ?? (map['id'] != null ? map['id'] as String : null),
      userId: map['userId'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      date: map['date'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotesModel.fromJson(String source) =>
      NotesModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
