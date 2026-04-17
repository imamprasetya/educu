import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SessionModel {
  int? id;
  int programId;
  final String topic;
  final String date;
  final String startTime;
  final String endTime;
  bool completed;

  SessionModel({
    this.id,
    required this.programId,
    required this.topic,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'programId': programId,
      'topic': topic,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'completed': completed ? 1 : 0, // SQLite doesn't have boolean, store as 1/0
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] != null ? map['id'] as int : null,
      programId: map['programId'] as int,
      topic: map['topic'] as String,
      date: map['date'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      completed: map['completed'] == 1,
    );
  }

  int get durationMinutes {
    try {
      final start = _parseTime(startTime);
      final end = _parseTime(endTime);
      if (start == null || end == null) return 25;
      final diff = end.difference(start).inMinutes;
      return diff > 0 ? diff : 25;
    } catch (_) {
      return 25;
    }
  }

  static DateTime? _parseTime(String time) {
    try {
      if (time.contains(':') && !time.contains(' ')) {
        final parts = time.split(':');
        return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      }
      final lower = time.toLowerCase().trim();
      final isPM = lower.contains('pm');
      final isAM = lower.contains('am');
      final cleaned = lower.replaceAll(RegExp(r'[ap]m'), '').trim();
      final parts = cleaned.split(':');
      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].trim());
      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;
      return DateTime(2000, 1, 1, hour, minute);
    } catch (_) {
      return null;
    }
  }

  String toJson() => json.encode(toMap());

  factory SessionModel.fromJson(String source) =>
      SessionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
