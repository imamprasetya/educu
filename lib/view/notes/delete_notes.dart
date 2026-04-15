import 'package:flutter/material.dart';
import 'package:educu_project/services/firebase_service.dart';

Future<void> showDeleteDialogNotes(BuildContext context, String id) async {
  final confirm = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah anda yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Hapus"),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    await FirebaseService.deleteNote(id);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Data berhasil dihapus")));
  }
}
