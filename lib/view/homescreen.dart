import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/models/user_model.dart';
import 'package:educu_project/view/home_content.dart';
import 'package:educu_project/view/schedule/schedule.dart';
import 'package:educu_project/view/profile/profile.dart';
import 'package:educu_project/view/programs/program.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const HomeContent(),
      const ScheduleScreen(),
      const ProgramScreen(),
      ProfileScreen(user: widget.user),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 214, 237, 255),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,

        currentIndex: _selectedIndex,

        onTap: _onItemTapped,

        selectedIconTheme: IconThemeData(color: AppColor.gradien2),

        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Jadwal",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Program",
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
