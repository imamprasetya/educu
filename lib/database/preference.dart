import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  // singleton
  static final PreferenceHandler _instance = PreferenceHandler._internal();

  late SharedPreferences _preferences;

  factory PreferenceHandler() => _instance;

  PreferenceHandler._internal();

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // key
  static const String _isLogin = 'isLogin';
  static const String _userId = 'userId';
  static const String _popupNotif = 'popupNotif';
  static const String _soundNotif = 'soundNotif';
  static const String _reminderMinutes = 'reminderMinutes';
  static const String _programSort = 'programSort';
  static const String _noteSort = 'noteSort';

  //  LOGIN STATUS

  // create
  Future<void> storingIsLogin(bool isLogin) async {
    await _preferences.setBool(_isLogin, isLogin);
  }

  // read
  static Future<bool?> getIsLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLogin);
  }

  // delete
  Future<void> deleteIsLogin() async {
    await _preferences.remove(_isLogin);
  }

  //  USER ID (now String for Firebase UID)

  // create user id
  Future<void> storingUserId(String uid) async {
    await _preferences.setString(_userId, uid);
  }

  // read user id
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userId);
  }

  // delete user id
  Future<void> deleteUserId() async {
    await _preferences.remove(_userId);
  }

  // ==================== NOTIFICATION SETTINGS ====================

  // Popup notifications (default: true)
  Future<void> setPopupNotif(bool value) async {
    await _preferences.setBool(_popupNotif, value);
  }

  bool getPopupNotif() {
    return _preferences.getBool(_popupNotif) ?? true;
  }

  // Sound notifications (default: true)
  Future<void> setSoundNotif(bool value) async {
    await _preferences.setBool(_soundNotif, value);
  }

  bool getSoundNotif() {
    return _preferences.getBool(_soundNotif) ?? true;
  }

  // Reminder minutes before session (default: 60)
  Future<void> setReminderMinutes(int minutes) async {
    await _preferences.setInt(_reminderMinutes, minutes);
  }

  int getReminderMinutes() {
    return _preferences.getInt(_reminderMinutes) ?? 60;
  }

  // SORT PREFERENCES
  Future<void> setProgramSort(String sort) async {
    await _preferences.setString(_programSort, sort);
  }

  String getProgramSort() {
    return _preferences.getString(_programSort) ?? 'startAsc';
  }

  Future<void> setNoteSort(String sort) async {
    await _preferences.setString(_noteSort, sort);
  }

  String getNoteSort() {
    return _preferences.getString(_noteSort) ?? 'titleAsc';
  }

  static const String _pomodoroSubject = 'pomodoroSubject';
  static const String _pomodoroTopic = 'pomodoroTopic';
  static const String _pomodoroSessionId = 'pomodoroSessionId';
  static const String _pomodoroStartTime = 'pomodoroStartTime';
  static const String _pomodoroEndTime = 'pomodoroEndTime';

  // POMODORO SESSION STORAGE
  Future<void> savePomodoroParams({
    required String subject,
    required String topic,
    String? sessionId,
    required String startTime,
    required String endTime,
  }) async {
    await _preferences.setString(_pomodoroSubject, subject);
    await _preferences.setString(_pomodoroTopic, topic);
    if (sessionId != null) {
      await _preferences.setString(_pomodoroSessionId, sessionId);
    } else {
      await _preferences.remove(_pomodoroSessionId);
    }
    await _preferences.setString(_pomodoroStartTime, startTime);
    await _preferences.setString(_pomodoroEndTime, endTime);
  }

  Map<String, String> getPomodoroParams() {
    return {
      'subject': _preferences.getString(_pomodoroSubject) ?? 'Belajar',
      'topic': _preferences.getString(_pomodoroTopic) ?? '',
      'sessionId': _preferences.getString(_pomodoroSessionId) ?? '',
      'startTime': _preferences.getString(_pomodoroStartTime) ?? '08:00',
      'endTime': _preferences.getString(_pomodoroEndTime) ?? '09:00',
    };
  }

  // clear all on logout
  Future<void> clearAll() async {
    await deleteIsLogin();
    await deleteUserId();
    await _preferences.remove(_pomodoroSubject);
    await _preferences.remove(_pomodoroTopic);
    await _preferences.remove(_pomodoroSessionId);
    await _preferences.remove(_pomodoroStartTime);
    await _preferences.remove(_pomodoroEndTime);
  }
}
