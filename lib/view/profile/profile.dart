import 'dart:convert';
import 'package:educu_project/models/user_model.dart';
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/constant/theme_notifier.dart';
import 'package:educu_project/view/auth/login.dart';
import 'package:educu_project/view/notes/notes_screen.dart';
import 'package:educu_project/view/profile/edit_profile.dart';
import 'package:flutter/material.dart';
import '../../constant/app_color.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool popupNotif = true;
  bool soundNotif = true;
  bool darkMode = ThemeNotifier().isDark;

  late String userName;
  late String userEmail;
  String? photoBase64;

  @override
  void initState() {
    super.initState();
    userName = widget.user.name ?? "User";
    userEmail = widget.user.email ?? "";
    photoBase64 = widget.user.photoBase64;
  }

  // Build avatar with photo
  Widget _buildAvatar() {
    ImageProvider? imageProvider;
    if (photoBase64 != null && photoBase64!.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(photoBase64!));
      } catch (_) {
        imageProvider = null;
      }
    }

    return CircleAvatar(
      radius: 35,
      backgroundColor: const Color(0xFF6C7AE0),
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? const Icon(Icons.person, color: Colors.white, size: 30)
          : null,
    );
  }

  // CONTACT US
  void contactUs() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Contact Us",
          style: TextStyle(color: AppColor.textPrimary(context)),
        ),

        content: Text(
          "Email : support@educu.com\nWebsite : www.educustudy.com",
          style: TextStyle(color: AppColor.textSecondary(context)),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // ABOUT APP
  void aboutApp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "About App",
          style: TextStyle(color: AppColor.textPrimary(context)),
        ),

        content: Text(
          "EduCu Study Planner\n\nVersion 1.0\n\nApplication to manage study schedules and improve productivity.",
          style: TextStyle(color: AppColor.textSecondary(context)),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // LOGOUT
  Future<void> _logout() async {
    await FirebaseService.signOut();
    await PreferenceHandler().clearAll();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // SETTINGS ITEM WIDGET
  Widget settingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColor.isDark(context)
                  ? Colors.white12
                  : Colors.grey.shade200,
              child: Icon(icon, color: AppColor.iconColor(context)),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColor.textPrimary(context),
                ),
              ),
            ),

            if (trailing != null) trailing,
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
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),

              width: double.infinity,

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.gradien1, AppColor.gradien2],
                ),

                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "Manage your account settings",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // PROFILE CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: AppColor.cardColor(context),

                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowColor(context),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),

              child: Column(
                children: [
                  Row(
                    children: [
                      _buildAvatar(),

                      const SizedBox(width: 15),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColor.textPrimary(context),
                            ),
                          ),
                          Text(
                            userEmail,
                            style: TextStyle(
                              color: AppColor.textHint(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.gradien2,
                        side: BorderSide(
                          color: AppColor.isDark(context)
                              ? AppColor.gradien2
                              : AppColor.gradien2,
                        ),
                      ),
                      onPressed: () async {
                        final updatedUser = await Navigator.push<UserModel>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              user: widget.user.copyWith(
                                name: userName,
                                email: userEmail,
                                photoBase64: photoBase64,
                              ),
                            ),
                          ),
                        );

                        if (updatedUser != null) {
                          setState(() {
                            userName = updatedUser.name ?? "User";
                            userEmail = updatedUser.email ?? "";
                            photoBase64 = updatedUser.photoBase64;
                          });
                        }
                      },
                      child: const Text("Edit Profile"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SETTINGS TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary(context),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // SETTINGS CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),

              decoration: BoxDecoration(
                color: AppColor.cardColor(context),

                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(color: AppColor.shadowColor(context), blurRadius: 4),
                ],
              ),

              child: Column(
                children: [
                  settingItem(
                    icon: Icons.notifications_none,
                    title: "Popup notifications",
                    trailing: Switch(
                      value: popupNotif,
                      onChanged: (value) {
                        setState(() {
                          popupNotif = value;
                        });
                      },
                    ),
                  ),

                  Divider(height: 1, color: AppColor.borderColor(context)),

                  settingItem(
                    icon: Icons.volume_up_outlined,
                    title: "Sound notifications",
                    trailing: Switch(
                      value: soundNotif,
                      onChanged: (value) {
                        setState(() {
                          soundNotif = value;
                        });
                      },
                    ),
                  ),

                  Divider(height: 1, color: AppColor.borderColor(context)),

                  settingItem(
                    icon: Icons.dark_mode_outlined,
                    title: "Dark mode",
                    trailing: Switch(
                      value: darkMode,
                      onChanged: (value) {
                        ThemeNotifier().toggleTheme(value);
                        setState(() {
                          darkMode = value;
                        });
                      },
                    ),
                  ),

                  Divider(height: 1, color: AppColor.borderColor(context)),

                  settingItem(
                    icon: Icons.notes,
                    title: "Notes",
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColor.iconColor(context),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotesScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: AppColor.borderColor(context)),

                  settingItem(
                    icon: Icons.mail_outline,
                    title: "Contact us",
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColor.iconColor(context),
                    ),
                    onTap: contactUs,
                  ),

                  Divider(height: 1, color: AppColor.borderColor(context)),

                  settingItem(
                    icon: Icons.info_outline,
                    title: "About app",
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColor.iconColor(context),
                    ),
                    onTap: aboutApp,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // LOGOUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: SizedBox(
                width: double.infinity,

                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),

                  onPressed: _logout,

                  icon: const Icon(Icons.logout),

                  label: const Text("Logout"),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
