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
      backgroundColor: AppColor.biru1,

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),

        backgroundColor: AppColor.gradien1,

        title: Text(
          widget.note == null ? "Add Note" : "Edit Note",
          style: const TextStyle(color: Colors.white),
        ),

        actions: [
          TextButton(
            onPressed: saveNote,
            child: const Text("Done", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Title"),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: "Write your note...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
