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

  // clear all on logout
  Future<void> clearAll() async {
    await deleteIsLogin();
    await deleteUserId();
  }
}
