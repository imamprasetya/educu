import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/services/notification_service.dart';
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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    autoLogin();
  }

  void autoLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    bool? isLogin = await PreferenceHandler.getIsLogin();

    if (isLogin == true) {
      // coba ambil data user dari Firebase
      UserModel? user = await FirebaseService.getCurrentUser();

      if (user != null) {
        // Schedule notifications after auto-login
        NotificationService().scheduleAllNotifications();
        context.pushAndRemoveAll(HomeScreen(user: user));
      } else {
        // user tidak ditemukan, clear preference dan ke login
        await PreferenceHandler().clearAll();
        context.pushAndRemoveAll(const LoginScreen());
      }
    } else {
      context.pushAndRemoveAll(const LoginScreen());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.gradien1, AppColor.gradien2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 120,
                    width: 120,
                  ),
                ),

                const SizedBox(height: 30),

                // App name
                const Text(
                  "EDUCU",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 6,
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  "Plan  •  Study  •  Succeed",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 50),

                // Loading indicator
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Colors.white.withValues(alpha: 0.7),
                    strokeWidth: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
