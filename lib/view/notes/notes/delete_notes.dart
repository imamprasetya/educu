import 'package:flutter/material.dart';
import 'package:educu_project/database/sqflite.dart';

Future<void> showDeleteDialogNotes(BuildContext context, int id) async {
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
    await DBHelper.deleteNote(id);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Data berhasil dihapus")));
  }
}
