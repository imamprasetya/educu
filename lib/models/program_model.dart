import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProgramModel {
  int? id;
  int userId;
  final String subject;
  final String startDate;
  final String endDate;
  final String description;

  ProgramModel({
    this.id,
    required this.userId,
    required this.subject,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'subject': subject,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }

  factory ProgramModel.fromMap(Map<String, dynamic> map) {
    return ProgramModel(
      id: map['id'] != null ? map['id'] as int : null,
      userId: map['userId'] as int,
      subject: map['subject'] as String,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProgramModel.fromJson(String source) =>
      ProgramModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
