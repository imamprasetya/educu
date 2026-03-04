import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/extension/navigator.dart';
import 'package:educu_project/view/homescreen.dart';
import 'package:educu_project/view/login.dart';
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
    await Future.delayed(Duration(seconds: 3));
    bool? data = await PreferenceHandler.getIsLogin();
    print(data);
    print("Hai");
    if (data == true) {
      context.pushAndRemoveAll(HomeScreen());
    } else {
      context.pushAndRemoveAll(LoginScreen());
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.navy,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/images/logo.png",
              height: 200,
              width: 200,
            ),
          ),
        ],
      ),
    );
  }
}
