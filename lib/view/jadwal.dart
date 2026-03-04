import 'package:educu_project/constant/app_color.dart';
import 'package:flutter/material.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        backgroundColor: AppColor.navy,
        title: Text(
          "Jadwal",
          style: TextStyle(color: AppColor.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
