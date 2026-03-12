import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  //Singleton
  static final PreferenceHandler _instance = PreferenceHandler._internal();
  late SharedPreferences _preferences;

  factory PreferenceHandler() => _instance;

  PreferenceHandler._internal();

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // KEY
  static const String _isLogin = 'isLogin';
  static const String _userId = 'userId';

  // LOGIN STATUS

  //CREATE
  Future<void> storingIsLogin(bool isLogin) async {
    await _preferences.setBool(_isLogin, isLogin);
  }

  //GET
  static Future<bool?> getIsLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLogin);
  }

  //DELETE
  Future<void> deleteIsLogin() async {
    await _preferences.remove(_isLogin);
  }

  // USER ID SESSION

  //CREATE USER ID
  Future<void> storingUserId(int id) async {
    await _preferences.setInt(_userId, id);
  }

  //GET USER ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userId);
  }

  //DELETE USER ID
  Future<void> deleteUserId() async {
    await _preferences.remove(_userId);
  }
}
