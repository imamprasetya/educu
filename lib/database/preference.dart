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

  //  USER ID

  // create user id
  Future<void> storingUserId(dynamic id) async {
    await _preferences.setString(_userId, id.toString());
  }

  // read user id
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    // Handle legacy int values and new String values
    final value = prefs.get(_userId);
    if (value == null) return null;
    return value.toString();
  }

  // delete user id
  Future<void> deleteUserId() async {
    await _preferences.remove(_userId);
  }

  // ==================== NOTIFICATION SETTINGS ====================
  static const String _popupNotif = 'popupNotif';
  static const String _soundNotif = 'soundNotif';
  static const String _reminderMinutes = 'reminderMinutes';

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

  // clear all on logout
  Future<void> clearAll() async {
    await deleteIsLogin();
    await deleteUserId();
  }
}
