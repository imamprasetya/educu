import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/models/user_model.dart';
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/database/sqflite.dart';
import 'package:educu_project/view/auth/register.dart';
import 'package:educu_project/view/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:educu_project/extension/navigator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    final UserModel? login = await DBHelper.loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    if (login != null) {
      await PreferenceHandler().storingIsLogin(true);
      await PreferenceHandler().storingUserId(login.id!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Login Successful"),
          backgroundColor: AppColor.gradien2,
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      context.pushReplacement(HomeScreen(user: login));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login failed, email or password is not registered"),
        ),
      );
    }
  }

  /// ALERT FEATURE IN DEVELOPMENT
  void showComingSoon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Feature Coming Soon"),
        content: const Text(
          "This login method is currently under development. Please use email and password to sign in.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.biru,

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Image.asset('assets/images/logo.png', height: 120, width: 120),

                const SizedBox(height: 10),

                Text(
                  'EDUCU',
                  style: TextStyle(
                    color: AppColor.logo,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Hello, Welcome Back",
                  style: TextStyle(
                    color: AppColor.gelap,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  "Sign in to your account. Have a good time",
                  style: TextStyle(color: Colors.blueGrey),
                ),

                const SizedBox(height: 35),

                const Row(children: [Text("Email")]),

                const SizedBox(height: 5),

                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Row(children: [Text("Password")]),

                const SizedBox(height: 5),

                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 45,
                  width: double.infinity,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: const Color.fromARGB(255, 0, 0, 51),
                    ),

                    onPressed: loginUser,

                    child: const Text(
                      "LOGIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Or Sign In With",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),

                const SizedBox(height: 20),

                /// GOOGLE & FACEBOOK BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: [
                    SizedBox(
                      height: 50,
                      width: 160,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            229,
                            243,
                            255,
                          ),
                        ),

                        onPressed: showComingSoon,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/google.png", height: 30),

                            const SizedBox(width: 8),

                            const Text(
                              "Google",
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 50,
                      width: 160,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            229,
                            243,
                            255,
                          ),
                        ),

                        onPressed: showComingSoon,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/facebook.png",
                              height: 30,
                            ),

                            const SizedBox(width: 8),

                            const Text(
                              "Facebook",
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.blueGrey),
                    ),

                    const SizedBox(width: 5),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 51),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
