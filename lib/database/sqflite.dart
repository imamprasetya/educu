import 'package:educu_project/models/notes_model.dart';
import 'package:educu_project/models/session_model.dart';
import 'package:educu_project/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> db() async {
    final dbPath = await getDatabasesPath();

    return openDatabase(
      join(dbPath, 'educu.db'),
      version: 4,

      onCreate: (db, version) async {
        // user table
        await db.execute('''
        CREATE TABLE user(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT,
          password TEXT,
          photoBase64 TEXT
        )
        ''');

        // program table
        await db.execute('''
        CREATE TABLE program(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          subject TEXT,
          startDate TEXT,
          endDate TEXT,
          description TEXT
        )
        ''');

        // session table
        await db.execute('''
        CREATE TABLE session(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          programId INTEGER,
          topic TEXT,
          date TEXT,
          startTime TEXT,
          endTime TEXT,
          completed INTEGER DEFAULT 0
        )
        ''');

        // notes table
        await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          title TEXT,
          content TEXT,
          date TEXT
        )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        // tambah tabel notes jika upgrade dari versi lama
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            title TEXT,
            content TEXT,
            date TEXT
          )
          ''');
        }

        // tambah kolom userId pada program
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE program ADD COLUMN userId INTEGER");
        }

        if (oldVersion < 4) {
          await db.execute("ALTER TABLE user ADD COLUMN photoBase64 TEXT");
          await db.execute("ALTER TABLE session ADD COLUMN completed INTEGER DEFAULT 0");
        }
      },
    );
  }

  // register user
  static Future<void> registerUser(UserModel user) async {
    final dbs = await db();
    await dbs.insert('user', user.toMap());
  }

  // login user
  static Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final dbs = await db();

    final result = await dbs.query(
      "user",
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }

    return null;
  }

  // update user
  static Future<void> updateUser(int id, Map<String, dynamic> data) async {
    final dbs = await db();
    await dbs.update("user", data, where: "id = ?", whereArgs: [id]);
  }

  // insert program
  static Future<int> insertProgram(Map<String, dynamic> data) async {
    final dbs = await db();
    return await dbs.insert("program", data);
  }

  // get program berdasarkan user
  static Future<List<Map<String, dynamic>>> getProgramsByUser(
    int userId,
  ) async {
    final dbs = await db();

    return await dbs.query(
      "program",
      where: "userId = ?",
      whereArgs: [userId],
      orderBy: "id DESC",
    );
  }

  // edit program
  static Future<void> updateProgram(int id, Map<String, dynamic> data) async {
    final dbs = await db();

    await dbs.update("program", data, where: "id = ?", whereArgs: [id]);
  }

  // delete program dan session
  static Future<void> deleteProgram(int id) async {
    final dbs = await db();

    // hapus session dulu
    await dbs.delete("session", where: "programId = ?", whereArgs: [id]);

    // hapus program
    await dbs.delete("program", where: "id = ?", whereArgs: [id]);
  }

  // insert session
  static Future<int> insertSession(SessionModel session) async {
    final dbs = await db();
    return await dbs.insert("session", session.toMap());
  }

  // update session
  static Future<void> updateSession(int id, Map<String, dynamic> data) async {
    final dbs = await db();
    await dbs.update("session", data, where: "id = ?", whereArgs: [id]);
  }

  // get session berdasarkan program
  static Future<List<Map<String, dynamic>>> getSessions(int programId) async {
    final dbs = await db();

    return await dbs.query(
      "session",
      where: "programId = ?",
      whereArgs: [programId],
    );
  }

  // delete session berdasarkan program
  static Future<void> deleteSessionsByProgram(int programId) async {
    final dbs = await db();

    await dbs.delete("session", where: "programId = ?", whereArgs: [programId]);
  }

  // delete satu session
  static Future<void> deleteSession(int id) async {
    final dbs = await db();
    await dbs.delete("session", where: "id = ?", whereArgs: [id]);
  }

  // insert notes
  static Future<int> insertNote(NotesModel note) async {
    final dbs = await db();
    return await dbs.insert("notes", note.toMap());
  }

  // get notes berdasarkan user
  static Future<List<NotesModel>> getNotesByUser(int userId) async {
    final dbs = await db();

    final result = await dbs.query(
      "notes",
      where: "userId = ?",
      whereArgs: [userId],
      orderBy: "id DESC",
    );

    return result.map((noteMap) => NotesModel.fromMap(noteMap)).toList();
  }

  // update notes
  static Future<void> updateNote(NotesModel note) async {
    final dbs = await db();

    if (note.id != null) {
      await dbs.update(
        "notes",
        note.toMap(),
        where: "id = ?",
        whereArgs: [note.id],
      );
    }
  }

  // delete notes
  static Future<void> deleteNote(int id) async {
    final dbs = await db();

    await dbs.delete("notes", where: "id = ?", whereArgs: [id]);
  }
}
