import 'package:educu_project/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> db() async {
    final dbPath = await getDatabasesPath();

    return openDatabase(
      join(dbPath, 'educu.db'),
      version: 2,

      onCreate: (db, version) async {
        // USER TABLE
        await db.execute('''
        CREATE TABLE user(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT,
          password TEXT
        )
        ''');

        // PROGRAM TABLE
        await db.execute('''
        CREATE TABLE program(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          subject TEXT,
          startDate TEXT,
          endDate TEXT,
          description TEXT
        )
        ''');

        // SESSION TABLE
        await db.execute('''
        CREATE TABLE session(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          programId INTEGER,
          topic TEXT,
          date TEXT,
          startTime TEXT,
          endTime TEXT
        )
        ''');

        // NOTES TABLE
        await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT,
          date TEXT
        )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            date TEXT
          )
          ''');
        }
      },
    );
  }

  // REGISTER USER
  static Future<void> registerUser(UserModel user) async {
    final dbs = await db();

    await dbs.insert('user', user.toMap());
  }

  // LOGIN USER
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

  // INSERT PROGRAM
  static Future<int> insertProgram(Map<String, dynamic> data) async {
    final dbs = await db();

    return await dbs.insert("program", data);
  }

  // GET PROGRAM
  static Future<List<Map<String, dynamic>>> getPrograms() async {
    final dbs = await db();

    return await dbs.query("program", orderBy: "id DESC");
  }

  // INSERT SESSION
  static Future<void> insertSession(Map<String, dynamic> data) async {
    final dbs = await db();

    await dbs.insert("session", data);
  }

  // GET SESSION BY PROGRAM
  static Future<List<Map<String, dynamic>>> getSessions(int programId) async {
    final dbs = await db();

    return await dbs.query(
      "session",
      where: "programId = ?",
      whereArgs: [programId],
    );
  }

  //Edit Program
  static Future<void> updateProgram(int id, Map<String, dynamic> data) async {
    final dbs = await db();

    await dbs.update("program", data, where: "id = ?", whereArgs: [id]);
  }

  //Delete Program dan Session
  static Future<void> deleteProgram(int id) async {
    final dbs = await db();

    // hapus session dulu
    await dbs.delete("session", where: "programId = ?", whereArgs: [id]);

    // hapus program
    await dbs.delete("program", where: "id = ?", whereArgs: [id]);
  }

  // DELETE SESSION BY PROGRAM
  static Future<void> deleteSessionsByProgram(int programId) async {
    final dbs = await db();

    await dbs.delete("session", where: "programId = ?", whereArgs: [programId]);
  }

  // NOTES
  static Future<int> insertNote(Map<String, dynamic> data) async {
    final dbs = await db();

    return await dbs.insert("notes", data);
  }

  static Future<List<Map<String, dynamic>>> getNotes() async {
    final dbs = await db();

    return await dbs.query("notes", orderBy: "id DESC");
  }

  static Future<void> updateNote(int id, Map<String, dynamic> data) async {
    final dbs = await db();

    await dbs.update("notes", data, where: "id = ?", whereArgs: [id]);
  }

  static Future<void> deleteNote(int id) async {
    final dbs = await db();

    await dbs.delete("notes", where: "id = ?", whereArgs: [id]);
  }
}
