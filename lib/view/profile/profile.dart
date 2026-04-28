import 'dart:convert';
import 'package:educu_project/models/user_model.dart';
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/services/notification_service.dart';
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
  int reminderMinutes = 60;

  late String userName;
  late String userEmail;
  String? photoBase64;

  @override
  void initState() {
    super.initState();
    userName = widget.user.name ?? "User";
    userEmail = widget.user.email ?? "";
    photoBase64 = widget.user.photoBase64;

    // Load notification settings from preferences
    final pref = PreferenceHandler();
    popupNotif = pref.getPopupNotif();
    soundNotif = pref.getSoundNotif();
    reminderMinutes = pref.getReminderMinutes();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Hubungi Kami",
          style: TextStyle(color: AppColor.textPrimary(context)),
        ),
        content: Text(
          "Email : educuproject@gmail.com",
          style: TextStyle(color: AppColor.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Tentang Aplikasi",
          style: TextStyle(color: AppColor.textPrimary(context)),
        ),
        content: Text(
          "Educu\n\nVersi 1.0\n\nAplikasi untuk mengelola jadwal belajar dan meningkatkan produktivitas.",
          style: TextStyle(color: AppColor.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  // LOGOUT CONFIRMATION DIALOG
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Konfirmasi Keluar",
          style: TextStyle(color: AppColor.textPrimary(context)),
        ),
        content: Text(
          "Apakah Anda yakin ingin keluar dari akun ini?",
          style: TextStyle(color: AppColor.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: TextStyle(color: AppColor.textHint(context)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // LOGOUT
  Future<void> _logout() async {
    // Cancel all notifications on logout
    await NotificationService().cancelAll();

    await FirebaseService.signOut();
    await PreferenceHandler().clearAll();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // Toggle popup notifications
  Future<void> _togglePopup(bool value) async {
    await PreferenceHandler().setPopupNotif(value);
    setState(() {
      popupNotif = value;
    });

    // Reschedule or cancel all notifications
    if (value) {
      NotificationService().scheduleAllNotifications();
    } else {
      NotificationService().cancelAll();
    }
  }

  // Toggle sound notifications
  Future<void> _toggleSound(bool value) async {
    await PreferenceHandler().setSoundNotif(value);
    setState(() {
      soundNotif = value;
    });

    // Reschedule notifications with updated sound setting
    NotificationService().scheduleAllNotifications();
  }

  // Change reminder time
  void _showReminderTimePicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Waktu Pengingat",
            style: TextStyle(
              color: AppColor.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Berapa menit sebelum sesi belajar kami harus mengingatkan Anda?",
            style: TextStyle(color: AppColor.textSecondary(context)),
          ),
          actions: [
            _reminderOption(15),
            _reminderOption(30),
            _reminderOption(60),
          ],
        );
      },
    );
  }

  Widget _reminderOption(int minutes) {
    final isSelected = reminderMinutes == minutes;
    final label = minutes == 60 ? "1 jam" : "$minutes mnt";

    return TextButton(
      onPressed: () async {
        await PreferenceHandler().setReminderMinutes(minutes);
        setState(() {
          reminderMinutes = minutes;
        });
        Navigator.pop(context);

        // Reschedule with new time
        NotificationService().scheduleAllNotifications();
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColor.gradien2 : AppColor.textHint(context),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: isSelected ? 16 : 14,
        ),
      ),
    );
  }

  // SETTINGS ITEM WIDGET
  Widget settingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColor.textPrimary(context),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.textHint(context),
                      ),
                    ),
                  ],
                ],
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
    final reminderLabel = reminderMinutes == 60
        ? "1 jam sebelumnya"
        : "$reminderMinutes mnt sebelumnya";

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
                  colors: AppColor.isDark(context)
                      ? [AppColor.darkSurface, AppColor.darkCard]
                      : [AppColor.gradien1, AppColor.gradien2],
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
                    "Profil",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Kelola pengaturan akun Anda",
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
                            style: TextStyle(color: AppColor.textHint(context)),
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
                        side: const BorderSide(color: AppColor.gradien2),
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
                      child: const Text("Edit Profil"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // NOTIFICATION SETTINGS TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Notifikasi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary(context),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // NOTIFICATION SETTINGS CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColor.cardColor(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowColor(context),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  settingItem(
                    icon: Icons.notifications_none,
                    title: "Notifikasi popup",
                    subtitle: popupNotif ? "Aktif" : "Nonaktif",
                    trailing: Switch(
                      value: popupNotif,
                      onChanged: _togglePopup,
                    ),
                  ),

                  Divider(height: 1, color: AppColor.borderColor(context)),

                  settingItem(
                    icon: Icons.volume_up_outlined,
                    title: "Notifikasi suara",
                    subtitle: soundNotif ? "Aktif" : "Bisukan",
                    trailing: Switch(
                      value: soundNotif,
                      onChanged: _toggleSound,
                    ),
                  ),

                  Divider(height: 1, color: AppColor.borderColor(context)),

                  settingItem(
                    icon: Icons.timer_outlined,
                    title: "Waktu pengingat",
                    subtitle: reminderLabel,
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColor.iconColor(context),
                    ),
                    onTap: _showReminderTimePicker,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // GENERAL SETTINGS TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Umum",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary(context),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // GENERAL SETTINGS CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColor.cardColor(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowColor(context),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  settingItem(
                    icon: Icons.dark_mode_outlined,
                    title: "Mode gelap",
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
                    title: "Catatan",
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
                    title: "Hubungi kami",
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColor.iconColor(context),
                    ),
                    onTap: contactUs,
                  ),

                  Divider(height: 1, color: AppColor.borderColor(context)),

                  settingItem(
                    icon: Icons.info_outline,
                    title: "Tentang aplikasi",
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
                  onPressed: _showLogoutDialog,
                  icon: const Icon(Icons.logout),
                  label: const Text("Keluar"),
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
