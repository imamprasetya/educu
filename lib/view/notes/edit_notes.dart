import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/models/notes_model.dart';
import 'package:flutter/material.dart';

class EditNoteScreen extends StatefulWidget {
  final NotesModel? note;

  const EditNoteScreen({super.key, this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  String? userId;

  @override
  void initState() {
    super.initState();
    getUser();

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }
  }

  // ambil user login
  Future<void> getUser() async {
    userId = FirebaseService.getCurrentUid();
  }

  void saveNote() async {
    if (userId == null) return;

    final note = NotesModel(
      id: widget.note?.id,
      userId: userId!, // untuk multi user
      title: titleController.text,
      content: contentController.text,
      date: DateTime.now().toString(),
    );

    if (widget.note == null) {
      await FirebaseService.insertNote(note);
    } else {
      await FirebaseService.updateNote(note);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),

        backgroundColor: AppColor.gradien1,

        title: Text(
          widget.note == null ? "Tambah Catatan" : "Edit Catatan",
          style: const TextStyle(color: Colors.white),
        ),

        actions: [
          TextButton(
            onPressed: saveNote,
            child: const Text("Selesai", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: AppColor.textPrimary(context)),
              decoration: InputDecoration(
                hintText: "Judul",
                hintStyle: TextStyle(color: AppColor.textHint(context)),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                style: TextStyle(color: AppColor.textPrimary(context)),
                decoration: InputDecoration(
                  hintText: "Tulis catatan Anda...",
                  hintStyle: TextStyle(color: AppColor.textHint(context)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColor.borderColor(context),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColor.borderColor(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColor.gradien2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
