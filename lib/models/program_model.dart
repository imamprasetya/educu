import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProgramModel {
  String? id;
  String userId;
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
      'userId': userId,
      'subject': subject,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }

  factory ProgramModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ProgramModel(
      id: docId ?? (map['id'] != null ? map['id'] as String : null),
      userId: map['userId'] as String,
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
