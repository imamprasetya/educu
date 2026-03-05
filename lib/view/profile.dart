import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/view/edit_profile.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool darkMode = false;
  bool notification = true;
  bool emailNotif = true;
  bool autoUpdate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.navy,
        title: Text(
          "Profile",
          style: TextStyle(color: AppColor.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// PROFILE CARD
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 252, 254, 255),
              borderRadius: BorderRadius.circular(15),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// FOTO + EDIT
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/300",
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColor.navy,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Text(
                  "Imam",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.navy,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// SETTINGS TITLE
          const Text(
            "Settings",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 10),

          /// DARK MODE
          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: const Icon(Icons.dark_mode),
            value: darkMode,
            onChanged: (value) {
              setState(() {
                darkMode = value;
              });
            },
          ),

          /// NOTIFICATION
          SwitchListTile(
            title: const Text("Push Notification"),
            secondary: const Icon(Icons.notifications),
            value: notification,
            onChanged: (value) {
              setState(() {
                notification = value;
              });
            },
          ),

          /// EMAIL NOTIFICATION
          SwitchListTile(
            title: const Text("Email Notification"),
            secondary: const Icon(Icons.email),
            value: emailNotif,
            onChanged: (value) {
              setState(() {
                emailNotif = value;
              });
            },
          ),

          /// AUTO UPDATE
          SwitchListTile(
            title: const Text("Auto Update App"),
            secondary: const Icon(Icons.system_update),
            value: autoUpdate,
            onChanged: (value) {
              setState(() {
                autoUpdate = value;
              });
            },
          ),

          const SizedBox(height: 40),

          /// LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
