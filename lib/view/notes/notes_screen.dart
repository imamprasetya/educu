import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/database/sqflite.dart';
import 'package:educu_project/view/notes/edit_notes.dart';
import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];
  List<Map<String, dynamic>> filteredNotes = [];

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final data = await DBHelper.getNotes();

    setState(() {
      notes = data;
      filteredNotes = data;
    });
  }

  void searchNotes(String value) {
    final result = notes.where((note) {
      final title = note['title'].toString().toLowerCase();

      return title.contains(value.toLowerCase());
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
      backgroundColor: AppColor.box1,

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
          // HEADER
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

              borderRadius: BorderRadius.only(
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
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    SizedBox(width: 15),
                    Text(
                      "My Notes",
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15),

                TextField(
                  controller: searchController,

                  onChanged: searchNotes,

                  decoration: InputDecoration(
                    hintText: "Search your notes...",

                    filled: true,

                    fillColor: AppColor.box,

                    prefixIcon: const Icon(Icons.search),

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

          // LIST NOTES
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
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(15),

                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
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
                              note['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              note['date'],
                              style: const TextStyle(
                                color: Colors.grey,
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
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),

                            onPressed: () {
                              deleteNote(note['id']);
                            },
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
