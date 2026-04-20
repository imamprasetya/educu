import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/view/auth/login.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //GRADIENT HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.gradien1, AppColor.gradien2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 60,
                      width: 60,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Buat Akun',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Bergabunglah dengan EduCu dan mulai perjalanan belajar Anda",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // ── FORM CONTENT ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FULL NAME
                    Text(
                      "Nama Lengkap",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary(context),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: namaController,
                      style: TextStyle(color: AppColor.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: "Masukkan nama lengkap Anda",
                        hintStyle: TextStyle(color: AppColor.textHint(context)),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppColor.iconColor(context),
                        ),
                        filled: true,
                        fillColor: AppColor.inputFill(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Nama lengkap harus diisi";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // EMAIL
                    Text(
                      "Email",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary(context),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: emailController,
                      style: TextStyle(color: AppColor.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: "Masukkan email Anda",
                        hintStyle: TextStyle(color: AppColor.textHint(context)),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColor.iconColor(context),
                        ),
                        filled: true,
                        fillColor: AppColor.inputFill(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email harus diisi";
                        }
                        if (!value.contains("@")) {
                          return "Email harus mengandung @";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // PASSWORD
                    Text(
                      "Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary(context),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: passwordController,
                      obscureText: isPasswordHidden,
                      style: TextStyle(color: AppColor.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: "Masukkan password Anda",
                        hintStyle: TextStyle(color: AppColor.textHint(context)),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColor.iconColor(context),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColor.iconColor(context),
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordHidden = !isPasswordHidden;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: AppColor.inputFill(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password harus diisi";
                        }
                        if (value.length < 6) {
                          return "Password minimal 6 karakter";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // CONFIRM PASSWORD
                    Text(
                      "Konfirmasi Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary(context),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: isConfirmPasswordHidden,
                      style: TextStyle(color: AppColor.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: "Masukkan kembali password Anda",
                        hintStyle: TextStyle(color: AppColor.textHint(context)),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColor.iconColor(context),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isConfirmPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColor.iconColor(context),
                          ),
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordHidden =
                                  !isConfirmPasswordHidden;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: AppColor.inputFill(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value != passwordController.text) {
                          return "Password tidak cocok";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // REGISTER BUTTON — gradient style (same as login)
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColor.gradien1, AppColor.gradien2],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.gradien2.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => isLoading = true);

                                  try {
                                    await FirebaseService.registerUser(
                                      name: namaController.text.trim(),
                                      email: emailController.text.trim(),
                                      password: passwordController.text,
                                    );

                                    // logout setelah register agar user login sendiri
                                    await FirebaseService.signOut();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Registrasi Berhasil! Silakan login.",
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );

                                    clearForm();

                                    // navigate ke login
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  } catch (e) {
                                    String message = "Registrasi gagal";

                                    if (e.toString().contains(
                                      "email-already-in-use",
                                    )) {
                                      message = "Email sudah terdaftar";
                                    } else if (e.toString().contains(
                                      "weak-password",
                                    )) {
                                      message =
                                          "Password terlalu lemah (minimal 6 karakter)";
                                    } else if (e.toString().contains(
                                      "invalid-email",
                                    )) {
                                      message = "Format email tidak valid";
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  }
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "DAFTAR",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // LOGIN LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun? ",
                          style: TextStyle(color: AppColor.textHint(context)),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Masuk",
                            style: TextStyle(
                              color: AppColor.gradien2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void clearForm() {
    _formKey.currentState?.reset();
    namaController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }
}
