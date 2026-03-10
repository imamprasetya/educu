import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/models/user_model.dart';
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/database/sqflite.dart';
import 'package:educu_project/view/auth/register.dart';
import 'package:educu_project/view/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:educu_project/extension/navigator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.biru,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 120, width: 120),
              Text(
                'EDUCU',
                style: TextStyle(
                  color: AppColor.logo,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              SizedBox(height: 10),

              Text(
                "Hello Welcome Back",
                style: TextStyle(
                  color: AppColor.gelap,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 7),
              Text(
                "Sign in to your account. Have a good time",
                style: TextStyle(color: Colors.blueGrey),
              ),

              SizedBox(height: 35),

              Row(children: [Text("Username")]),
              SizedBox(height: 5),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Masukkan username Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Row(children: [Text("Password")]),
              SizedBox(height: 5),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Masukkan password Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              SizedBox(height: 20),

              //Lupa Password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 119),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              SizedBox(
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(30),
                    ),
                    backgroundColor: Color.fromARGB(255, 0, 0, 51),
                  ),
                  onPressed: () async {
                    final UserModel? login = await DBHelper.loginUser(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    if (login != null) {
                      PreferenceHandler().storingIsLogin(true);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Login Berhasil")));
                      await Future.delayed(Duration(seconds: 2));
                      context.pushReplacement(HomeScreen());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Login gagal, email atau password tidak terdaftar",
                          ),
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "LOGIN",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              //Sign In With
              Row(
                children: [
                  Expanded(
                    child: Divider(thickness: 1, color: Colors.blueGrey),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Or Sign In With",
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ),
                  Expanded(
                    child: Divider(thickness: 1, color: Colors.blueGrey),
                  ),
                ],
              ),
              SizedBox(height: 20),

              //Sosmed
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
                        backgroundColor: Color.fromARGB(255, 229, 243, 255),
                      ),
                      onPressed: () async {
                        var dataIsLogin = PreferenceHandler.getIsLogin();
                        print(dataIsLogin);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/google.png", height: 30),
                          SizedBox(width: 8),
                          Text(
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
                        backgroundColor: Color.fromARGB(255, 229, 243, 255),
                      ),
                      onPressed: () async {
                        var dataIsLogin = PreferenceHandler.getIsLogin();
                        print(dataIsLogin);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/facebook.png", height: 30),
                          SizedBox(width: 8),
                          Text(
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
              SizedBox(height: 35),

              //Punya akun?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
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
    );
  }
}
