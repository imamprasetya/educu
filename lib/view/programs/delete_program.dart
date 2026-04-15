import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/constant/app_color.dart';
import 'package:flutter/material.dart';

Future<void> showDeleteDialog(BuildContext context, String id) async {
  final confirm = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 50),
            SizedBox(height: 10),
            Text("Delete Confirmation", textAlign: TextAlign.center),
          ],
        ),
        content: const Text(
          "Are you sure you want to delete this program?",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.gradien1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    await FirebaseService.deleteProgram(id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Program deleted successfully")),
    );
  }
}
