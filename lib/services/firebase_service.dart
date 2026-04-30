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

  // Register user dengan email & password, simpan profil ke Firestore
  // Otomatis kirim email verifikasi setelah registrasi
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
    final model = UserModel(uid: user.uid, email: email, name: name);

    await _firestore.collection('users').doc(user.uid).set(model.toMap());

    // Kirim email verifikasi
    await user.sendEmailVerification();

    return model;
  }

  // Kirim ulang email verifikasi
  static Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Cek apakah email sudah terverifikasi
  static Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return user.emailVerified;
  }

  // Login user dengan email & password, ambil profil dari Firestore
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

  // Ambil data user yang sedang login dari Firestore
  static Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return UserModel(uid: user.uid, email: user.email, name: '');
  }

  // Get current Firebase Auth UID
  static String? getCurrentUid() {
    return _auth.currentUser?.uid;
  }

  // Logout
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Kirim email reset password
  static Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Ganti password (perlu re-authenticate dulu)
  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User tidak ditemukan');
    }

    // Re-authenticate dengan password lama
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Update ke password baru
    await user.updatePassword(newPassword);
  }

  // Update profil user di Firestore
  static Future<void> updateUser(UserModel user) async {
    if (user.uid == null) return;
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  // ==================== PROGRAMS ====================

  // Insert program ke Firestore, return document ID
  static Future<String> insertProgram(Map<String, dynamic> data) async {
    final uid = getCurrentUid();
    if (uid == null) throw Exception('User not logged in');

    data['userId'] = uid;
    final docRef = await _firestore.collection('programs').add(data);
    return docRef.id;
  }

  // Get programs berdasarkan user yang login
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

  // Update program
  static Future<void> updateProgram(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('programs').doc(id).update(data);
  }

  // Update session
  static Future<void> updateSession(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('sessions').doc(id).update(data);
  }

  // Delete single session
  static Future<void> deleteSession(String id) async {
    await _firestore.collection('sessions').doc(id).delete();
  }

  // Delete program dan sessions-nya
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

  // Insert session ke Firestore, return document ID
  static Future<String> insertSession(SessionModel session) async {
    final docRef = await _firestore.collection('sessions').add(session.toMap());
    return docRef.id;
  }

  // Get sessions berdasarkan program
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

  // Delete sessions berdasarkan program
  static Future<void> deleteSessionsByProgram(String programId) async {
    final snapshot = await _firestore
        .collection('sessions')
        .where('programId', isEqualTo: programId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Get sessions berdasarkan tanggal (untuk schedule)
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

  // Mark session sebagai selesai
  static Future<void> markSessionCompleted(String sessionId) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'completed': true,
    });
  }

  // Get sessions sebagai List<SessionModel>
  static Future<List<SessionModel>> getSessionModels(String programId) async {
    final snapshot = await _firestore
        .collection('sessions')
        .where('programId', isEqualTo: programId)
        .get();

    return snapshot.docs.map((doc) {
      return SessionModel.fromMap(doc.data(), docId: doc.id);
    }).toList();
  }

  // Hitung progress program (completed sessions / total sessions)
  static Future<double> getProgramProgress(String programId) async {
    final sessions = await getSessionModels(programId);
    if (sessions.isEmpty) return 0.0;
    final completed = sessions.where((s) => s.completed).length;
    return completed / sessions.length;
  }

  // ==================== NOTES ====================

  // Insert note ke Firestore
  static Future<String> insertNote(NotesModel note) async {
    final docRef = await _firestore.collection('notes').add(note.toMap());
    return docRef.id;
  }

  // Get notes berdasarkan user
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

  // Update note
  static Future<void> updateNote(NotesModel note) async {
    if (note.id == null) return;
    await _firestore.collection('notes').doc(note.id).update(note.toMap());
  }

  // Delete note
  static Future<void> deleteNote(String id) async {
    await _firestore.collection('notes').doc(id).delete();
  }
}
