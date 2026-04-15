import 'package:educu_project/models/user_model.dart';
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/view/auth/login.dart';
import 'package:educu_project/view/notes/notes_screen.dart';
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
  bool darkMode = false;

  late String userName;
  late String userEmail;

  @override
  void initState() {
    super.initState();
    userName = widget.user.name ?? "User";
    userEmail = widget.user.email ?? "";
  }

  /// CONTACT US
  void contactUs() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Contact Us"),

        content: const Text(
          "Email : support@educu.com\nWebsite : www.educustudy.com",
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

  /// ABOUT APP
  void aboutApp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("About App"),

        content: const Text(
          "EduCu Study Planner\n\nVersion 1.0\n\nApplication to manage study schedules and improve productivity.",
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

  /// LOGOUT
  Future<void> _logout() async {
    await FirebaseService.signOut();
    await PreferenceHandler().clearAll();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
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
              backgroundColor: Colors.grey.shade200,
              child: Icon(icon, color: Colors.grey),
            ),

            const SizedBox(width: 15),

            Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),

            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F6),

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
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),

              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Color(0xFF6C7AE0),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            userEmail,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,

                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Edit profile feature coming soon"),
                          ),
                        );
                      },

                      child: const Text("Edit Profile"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SETTINGS TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Settings",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // SETTINGS CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
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

                  const Divider(height: 1),

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

                  const Divider(height: 1),

                  settingItem(
                    icon: Icons.dark_mode_outlined,
                    title: "Dark mode",
                    trailing: Switch(
                      value: darkMode,
                      onChanged: (value) {
                        setState(() {
                          darkMode = value;
                        });
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  settingItem(
                    icon: Icons.notes,
                    title: "Notes",
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotesScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),

                  settingItem(
                    icon: Icons.mail_outline,
                    title: "Contact us",
                    trailing: const Icon(Icons.chevron_right),
                    onTap: contactUs,
                  ),

                  const Divider(height: 1),

                  settingItem(
                    icon: Icons.info_outline,
                    title: "About app",
                    trailing: const Icon(Icons.chevron_right),
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
