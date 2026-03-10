import 'package:flutter/material.dart';

class ProgramDetail extends StatefulWidget {
  const ProgramDetail({super.key});

  @override
  State<ProgramDetail> createState() => _ProgramDetailState();
}

class _ProgramDetailState extends State<ProgramDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: Colors.redAccent));
  }
}
