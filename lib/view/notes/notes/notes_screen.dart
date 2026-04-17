import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/database/sqflite.dart';
import 'package:educu_project/database/preference.dart';
import 'package:educu_project/models/notes_model.dart';
import 'package:educu_project/view/notes/edit_notes.dart';
import 'package:educu_project/view/notes/delete_notes.dart';
import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<NotesModel> notes = [];
  List<NotesModel> filteredNotes = [];

  final searchController = TextEditingController();

  int? userId;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  // ambil user login
  Future<void> getUser() async {
    final userIdStr = await PreferenceHandler.getUserId();
    if (userIdStr != null) {
      userId = int.parse(userIdStr);
      loadNotes();
    }
  }

  Future<void> loadNotes() async {
    if (userId == null) return;

    final data = await DBHelper.getNotesByUser(userId!);

    setState(() {
      notes = data;
      filteredNotes = data;
    });
  }

  void searchNotes(String value) {
    final result = notes.where((note) {
      return note.title.toLowerCase().contains(value.toLowerCase());
    }).toList();

    setState(() {
      filteredNotes = result;
    });
  }

  void deleteNote(int id) async {
    await DBHelper.deleteNote(id);
    loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditNoteScreen()),
          );

          loadNotes();
        },

        backgroundColor: Colors.blue,

        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.gradien2, AppColor.gradien1],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),

                    const SizedBox(width: 15),

                    const Text(
                      "My Notes",
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: searchController,
                  onChanged: searchNotes,
                  style: TextStyle(color: AppColor.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: "Search your notes...",
                    hintStyle: TextStyle(color: AppColor.textHint(context)),
                    filled: true,
                    fillColor: AppColor.searchBox(context),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColor.iconColor(context),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),

                  padding: const EdgeInsets.all(15),

                  decoration: BoxDecoration(
                    color: AppColor.cardColor(context),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.shadowColor(context),
                        blurRadius: 4,
                      ),
                    ],
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              note.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColor.textPrimary(context),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              note.content,
                              style: TextStyle(
                                color: AppColor.textHint(context),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: AppColor.gradien2,
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditNoteScreen(note: note),
                                ),
                              );
                              loadNotes();
                            },
                          ),

                          IconButton(
                            onPressed: () async {
                              if (note.id != null) {
                                await showDeleteDialogNotes(context, note.id!);
                                await loadNotes();
                              }
                            },
                            icon: const Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
