import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educu_project/models/notes_model.dart';
import 'package:educu_project/models/program_model.dart';
import 'package:educu_project/models/session_model.dart';
import 'package:educu_project/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== AUTH ====================

  /// Register user dengan email & password, simpan profil ke Firestore
  static Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user!;
    final model = UserModel(
      uid: user.uid,
      email: email,
      name: name,
    );

    await _firestore.collection('users').doc(user.uid).set(model.toMap());
    return model;
  }

  /// Login user dengan email & password, ambil profil dari Firestore
  static Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user!;
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    } else {
      // fallback: jika dokumen belum ada
      return UserModel(uid: user.uid, email: user.email, name: '');
    }
  }

  /// Ambil data user yang sedang login dari Firestore
  static Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return UserModel(uid: user.uid, email: user.email, name: '');
  }

  /// Get current Firebase Auth UID
  static String? getCurrentUid() {
    return _auth.currentUser?.uid;
  }

  /// Logout
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Update profil user di Firestore
  static Future<void> updateUser(UserModel user) async {
    if (user.uid == null) return;
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  // ==================== PROGRAMS ====================

  /// Insert program ke Firestore, return document ID
  static Future<String> insertProgram(Map<String, dynamic> data) async {
    final uid = getCurrentUid();
    if (uid == null) throw Exception('User not logged in');

    data['userId'] = uid;
    final docRef = await _firestore.collection('programs').add(data);
    return docRef.id;
  }

  /// Get programs berdasarkan user yang login
  static Future<List<ProgramModel>> getProgramsByUser(String userId) async {
    final snapshot = await _firestore
        .collection('programs')
        .where('userId', isEqualTo: userId)
        .orderBy(FieldPath.documentId, descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return ProgramModel.fromMap(doc.data(), docId: doc.id);
    }).toList();
  }

  /// Update program
  static Future<void> updateProgram(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('programs').doc(id).update(data);
  }

  /// Delete program dan sessions-nya
  static Future<void> deleteProgram(String id) async {
    // hapus semua session milik program ini
    final sessions = await _firestore
        .collection('sessions')
        .where('programId', isEqualTo: id)
        .get();

    for (var doc in sessions.docs) {
      await doc.reference.delete();
    }

    // hapus program
    await _firestore.collection('programs').doc(id).delete();
  }

  // ==================== SESSIONS ====================

  /// Insert session ke Firestore, return document ID
  static Future<String> insertSession(SessionModel session) async {
    final docRef =
        await _firestore.collection('sessions').add(session.toMap());
    return docRef.id;
  }

  /// Get sessions berdasarkan program
  static Future<List<Map<String, dynamic>>> getSessions(
    String programId,
  ) async {
    final snapshot = await _firestore
        .collection('sessions')
        .where('programId', isEqualTo: programId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Delete sessions berdasarkan program
  static Future<void> deleteSessionsByProgram(String programId) async {
    final snapshot = await _firestore
        .collection('sessions')
        .where('programId', isEqualTo: programId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Get sessions berdasarkan tanggal (untuk schedule)
  static Future<List<Map<String, dynamic>>> getSessionsByDate(
    String date,
  ) async {
    final uid = getCurrentUid();
    if (uid == null) return [];

    // ambil semua program milik user ini
    final programs = await _firestore
        .collection('programs')
        .where('userId', isEqualTo: uid)
        .get();

    final programIds = programs.docs.map((doc) => doc.id).toList();

    if (programIds.isEmpty) return [];

    List<Map<String, dynamic>> result = [];

    // Firestore 'whereIn' max 30 items, so batch if needed
    for (var i = 0; i < programIds.length; i += 30) {
      final batch = programIds.sublist(
        i,
        i + 30 > programIds.length ? programIds.length : i + 30,
      );

      final sessions = await _firestore
          .collection('sessions')
          .where('programId', whereIn: batch)
          .where('date', isEqualTo: date)
          .get();

      for (var doc in sessions.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // cari subject dari program
        final programDoc = programs.docs.firstWhere(
          (p) => p.id == data['programId'],
        );
        data['subject'] = programDoc.data()['subject'];

        result.add(data);
      }
    }

    return result;
  }

  // ==================== NOTES ====================

  /// Insert note ke Firestore
  static Future<String> insertNote(NotesModel note) async {
    final docRef = await _firestore.collection('notes').add(note.toMap());
    return docRef.id;
  }

  /// Get notes berdasarkan user
  static Future<List<NotesModel>> getNotesByUser(String userId) async {
    final snapshot = await _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .orderBy(FieldPath.documentId, descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return NotesModel.fromMap(doc.data(), docId: doc.id);
    }).toList();
  }

  /// Update note
  static Future<void> updateNote(NotesModel note) async {
    if (note.id == null) return;
    await _firestore.collection('notes').doc(note.id).update(note.toMap());
  }

  /// Delete note
  static Future<void> deleteNote(String id) async {
    await _firestore.collection('notes').doc(id).delete();
  }
}
