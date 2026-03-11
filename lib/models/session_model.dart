// import 'dart:convert';

// // ignore_for_file: public_member_api_docs, sort_constructors_first
// class SessionModel {
//   int? id;
//   int programId;
//   final String topic;
//   final String date;
//   final String startTime;
//   final String endTime;
//   SessionModel({
//     this.id,
//     required this.programId,
//     required this.topic,
//     required this.date,
//     required this.startTime,
//     required this.endTime,
//   });

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'id': id,
//       'programId': programId,
//       'topic': topic,
//       'date': date,
//       'startTime': startTime,
//       'endTime': endTime,
//     };
//   }

//   factory SessionModel.fromMap(Map<String, dynamic> map) {
//     return SessionModel(
//       id: map['id'] != null ? map['id'] as int : null,
//       programId: map['programId'] as int,
//       topic: map['topic'] as String,
//       date: map['date'] as String,
//       startTime: map['startTime'] as String,
//       endTime: map['endTime'] as String,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory SessionModel.fromJson(String source) =>
//       SessionModel.fromMap(json.decode(source) as Map<String, dynamic>);
// }
