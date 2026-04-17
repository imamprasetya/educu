import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/database/sqflite.dart';
import 'package:educu_project/models/user_model.dart';
import 'package:educu_project/extension/navigator.dart';
import 'package:educu_project/view/homescreen.dart';
import 'package:educu_project/view/auth/login.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  void autoLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    bool? isLogin = await PreferenceHandler.getIsLogin();

    if (isLogin == true) {
      String? userId = await PreferenceHandler.getUserId();

      final db = await DBHelper.db();

      final result = await db.query(
        "user",
        where: "id = ?",
        whereArgs: [int.tryParse(userId ?? '')],
      );

      if (result.isNotEmpty) {
        UserModel user = UserModel.fromMap(result.first);

        context.pushAndRemoveAll(HomeScreen(user: user));
      } else {
        context.pushAndRemoveAll(const LoginScreen());
      }
    } else {
      context.pushAndRemoveAll(const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.navy,
      body: Center(
        child: Image.asset("assets/images/logo.png", height: 200, width: 200),
      ),
    );
  }
}
