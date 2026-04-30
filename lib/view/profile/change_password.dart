import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isChangingPassword = false;
  bool hideOldPassword = true;
  bool hideNewPassword = true;
  bool hideConfirmPassword = true;

  // Ganti password
  Future<void> _changePassword() async {
    final oldPw = oldPasswordController.text;
    final newPw = newPasswordController.text;
    final confirmPw = confirmPasswordController.text;

    if (oldPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua kolom password")),
      );
      return;
    }

    if (newPw.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password baru minimal 6 karakter")),
      );
      return;
    }

    if (newPw != confirmPw) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password baru tidak cocok")),
      );
      return;
    }

    if (oldPw == newPw) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password baru tidak boleh sama dengan password lama"),
        ),
      );
      return;
    }

    setState(() => isChangingPassword = true);

    try {
      await FirebaseService.changePassword(
        oldPassword: oldPw,
        newPassword: newPw,
      );

      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password berhasil diubah!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      String message = "Gagal mengubah password";
      if (e.toString().contains("wrong-password") ||
          e.toString().contains("invalid-credential")) {
        message = "Password lama salah";
      } else if (e.toString().contains("weak-password")) {
        message = "Password baru terlalu lemah";
      } else if (e.toString().contains("requires-recent-login")) {
        message = "Silakan logout dan login ulang terlebih dahulu";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) setState(() => isChangingPassword = false);
    }
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback toggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(color: AppColor.textPrimary(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColor.textHint(context)),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AppColor.iconColor(context),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: AppColor.iconColor(context),
              ),
              onPressed: toggleVisibility,
            ),
            filled: true,
            fillColor: AppColor.inputFill(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor:
            AppColor.isDark(context) ? AppColor.darkSurface : AppColor.gradien1,
        title: const Text(
          "Kata Sandi dan Keamanan",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Icon header
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.isDark(context)
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColor.gradien2.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield_outlined,
                size: 50,
                color: AppColor.gradien2,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              "Ubah kata sandi Anda",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary(context),
              ),
            ),
          ),

          const SizedBox(height: 5),

          Center(
            child: Text(
              "Pastikan kata sandi baru Anda kuat dan mudah diingat",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColor.textHint(context),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Password Lama
          _passwordField(
            controller: oldPasswordController,
            label: "Password Lama",
            hint: "Masukkan password lama",
            obscure: hideOldPassword,
            toggleVisibility: () =>
                setState(() => hideOldPassword = !hideOldPassword),
          ),

          const SizedBox(height: 18),

          // Password Baru
          _passwordField(
            controller: newPasswordController,
            label: "Password Baru",
            hint: "Masukkan password baru (min. 6 karakter)",
            obscure: hideNewPassword,
            toggleVisibility: () =>
                setState(() => hideNewPassword = !hideNewPassword),
          ),

          const SizedBox(height: 18),

          // Konfirmasi Password Baru
          _passwordField(
            controller: confirmPasswordController,
            label: "Konfirmasi Password Baru",
            hint: "Masukkan ulang password baru",
            obscure: hideConfirmPassword,
            toggleVisibility: () =>
                setState(() => hideConfirmPassword = !hideConfirmPassword),
          ),

          const SizedBox(height: 30),

          // TOMBOL UBAH PASSWORD
          GestureDetector(
            onTap: isChangingPassword ? null : _changePassword,
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
                          color: AppColor.gradien2.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: isChangingPassword
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "UBAH PASSWORD",
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

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
