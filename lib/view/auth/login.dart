import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/models/user_model.dart';
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/services/notification_service.dart';
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

  bool isPasswordHidden = true;
  bool isLoading = false;

  Future<void> loginUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Harap isi semua kolom")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final UserModel user = await FirebaseService.loginUser(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Cek apakah email sudah terverifikasi
      final verified = await FirebaseService.isEmailVerified();
      if (!verified) {
        if (!mounted) return;

        // Tampilkan dialog verifikasi
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Email Belum Diverifikasi",
                    style: TextStyle(
                      color: AppColor.textPrimary(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              "Silakan cek email Anda dan klik link verifikasi terlebih dahulu sebelum login.",
              style: TextStyle(color: AppColor.textSecondary(context)),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    // Re-login dulu untuk bisa kirim ulang verifikasi
                    await FirebaseService.loginUser(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                    );
                    await FirebaseService.resendEmailVerification();
                    await FirebaseService.signOut();
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Email verifikasi telah dikirim ulang"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Gagal mengirim ulang. Coba lagi nanti.",
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text("KIRIM ULANG"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );

        // Logout karena belum terverifikasi
        await FirebaseService.signOut();
        return;
      }

      await PreferenceHandler().storingIsLogin(true);
      await PreferenceHandler().storingUserId(user.uid!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Berhasil"),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      // Schedule notifications after login
      NotificationService().scheduleAllNotifications();

      context.pushReplacement(HomeScreen(user: user));
    } catch (e) {
      String message = "Login gagal";
      if (e.toString().contains("user-not-found")) {
        message = "Tidak ada akun dengan email ini";
      } else if (e.toString().contains("wrong-password") ||
          e.toString().contains("invalid-credential")) {
        message = "Email atau password salah";
      } else if (e.toString().contains("invalid-email")) {
        message = "Format email tidak valid";
      } else if (e.toString().contains("too-many-requests")) {
        message = "Terlalu banyak percobaan. Silakan coba lagi nanti";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ALERT FEATURE IN DEVELOPMENT
  void showComingSoon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Fitur Akan Datang",
          style: TextStyle(color: AppColor.textPrimary(context)),
        ),
        content: Text(
          "Metode login ini sedang dalam pengembangan. Silakan gunakan email dan password untuk masuk.",
          style: TextStyle(color: AppColor.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // DIALOG LUPA PASSWORD
  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: emailController.text.trim(),
    );
    bool isSending = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.lock_reset, color: AppColor.gradien2, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Lupa Password",
                  style: TextStyle(
                    color: AppColor.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Masukkan email Anda, kami akan mengirim link untuk mereset password.",
                style: TextStyle(
                  color: AppColor.textSecondary(context),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                style: TextStyle(color: AppColor.textPrimary(context)),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColor.iconColor(context),
                  ),
                  hintText: "Masukkan email Anda",
                  hintStyle: TextStyle(color: AppColor.textHint(context)),
                  filled: true,
                  fillColor: AppColor.inputFill(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "BATAL",
                style: TextStyle(color: AppColor.textHint(context)),
              ),
            ),
            TextButton(
              onPressed: isSending
                  ? null
                  : () async {
                      final email = resetEmailController.text.trim();
                      if (email.isEmpty || !email.contains("@")) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Masukkan email yang valid"),
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSending = true);

                      try {
                        await FirebaseService.sendPasswordReset(email);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Link reset password telah dikirim ke email Anda",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSending = false);
                        String msg = "Gagal mengirim email reset";
                        if (e.toString().contains("user-not-found")) {
                          msg = "Email tidak terdaftar";
                        } else if (e.toString().contains("invalid-email")) {
                          msg = "Format email tidak valid";
                        } else if (e.toString().contains("too-many-requests")) {
                          msg = "Terlalu banyak percobaan. Coba lagi nanti";
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                        }
                      }
                    },
              child: isSending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("KIRIM"),
            ),
          ],
        ),
      ),
    );
  }

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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColor.gradientColors(context),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
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
                      height: 70,
                      width: 70,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'EDUCU',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      letterSpacing: 4,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Selamat datang kembali! Masuk untuk melanjutkan",
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
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Masuk",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary(context),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Masukkan kredensial Anda untuk mengakses akun",
                    style: TextStyle(
                      color: AppColor.textHint(context),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 25),

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
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColor.iconColor(context),
                      ),
                      hintText: 'Masukkan email Anda',
                      hintStyle: TextStyle(color: AppColor.textHint(context)),
                      filled: true,
                      fillColor: AppColor.inputFill(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColor.iconColor(context),
                      ),
                      hintText: 'Masukkan password Anda',
                      hintStyle: TextStyle(color: AppColor.textHint(context)),
                      filled: true,
                      fillColor: AppColor.inputFill(context),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  //Lupa Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _showForgotPasswordDialog(),
                      child: Text(
                        "Lupa Password?",
                        style: TextStyle(
                          color: AppColor.accentColor(context),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // LOGIN BUTTON
                  GestureDetector(
                    onTap: isLoading ? null : loginUser,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColor.gradien1, AppColor.gradien2],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: AppColor.isDark(context)
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColor.gradien2.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Center(
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
                                "MASUK",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // OR SIGN IN WITH
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: AppColor.borderColor(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "Atau masuk dengan",
                          style: TextStyle(
                            color: AppColor.textHint(context),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: AppColor.borderColor(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // GOOGLE & FACEBOOK
                  Row(
                    children: [
                      Expanded(
                        child: _socialButton(
                          "assets/images/google.png",
                          "Google",
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _socialButton(
                          "assets/images/facebook.png",
                          "Facebook",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // SIGN UP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Belum punya akun? ",
                        style: TextStyle(color: AppColor.textHint(context)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Daftar",
                          style: TextStyle(
                            color: AppColor.accentColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Social login button — same card style as the rest of the app
  Widget _socialButton(String assetPath, String label) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor(context),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: showComingSoon,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(assetPath, height: 24),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: AppColor.textPrimary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
