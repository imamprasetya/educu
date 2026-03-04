import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  //Inisialisasi Shared Preference
  static final PreferenceHandler _instance = PreferenceHandler._internal();
  late SharedPreferences _preferences;
  factory PreferenceHandler() => _instance;
  PreferenceHandler._internal();
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  //Key user
  static const String _isLogin = 'isLogin';

  //CREATE
  Future<void> storingIsLogin(bool isLogin) async {
    // final prefs = await SharedPreferences.getInstance();
    _preferences.setBool(_isLogin, isLogin);
  }

  //GET
  static Future<bool?> getIsLogin() async {
    final prefs = await SharedPreferences.getInstance();

    var data = prefs.getBool(_isLogin);
    return data;
  }

  //DELETE
  Future<void> deleteIsLogin() async {
    await _preferences.remove(_isLogin);
  }
}
