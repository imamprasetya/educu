import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/services/firebase_service.dart';
import 'package:educu_project/models/notes_model.dart';
import 'package:educu_project/view/notes/edit_notes.dart';
import 'package:educu_project/view/notes/delete_notes.dart';
import 'package:educu_project/database/preference.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

enum NoteSortOption { titleAsc, dateAsc, dateDesc }

class _NotesScreenState extends State<NotesScreen> {
  List<NotesModel> notes = [];
  List<NotesModel> filteredNotes = [];

  final searchController = TextEditingController();

  String? userId;
  NoteSortOption _sortOption = NoteSortOption.dateDesc;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    
    final savedSort = PreferenceHandler().getNoteSort();
    _sortOption = NoteSortOption.values.firstWhere(
      (e) => e.name == savedSort,
      orElse: () => NoteSortOption.dateDesc,
    );

    getUser();
  }

  // ambil user login
  Future<void> getUser() async {
    userId = FirebaseService.getCurrentUid();
    loadNotes();
  }

  void applySort() {
    setState(() {
      if (_sortOption == NoteSortOption.titleAsc) {
        filteredNotes.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      } else if (_sortOption == NoteSortOption.dateAsc) {
        filteredNotes.sort((a, b) => a.date.compareTo(b.date));
      } else if (_sortOption == NoteSortOption.dateDesc) {
        filteredNotes.sort((a, b) => b.date.compareTo(a.date));
      }
    });
  }

  Future<void> loadNotes() async {
    if (userId == null) return;

    final data = await FirebaseService.getNotesByUser(userId!);

    setState(() {
      notes = data;
      filteredNotes = List.from(data);
    });
    applySort();
  }

  void searchNotes(String value) {
    final result = notes.where((note) {
      return note.title.toLowerCase().contains(value.toLowerCase());
    }).toList();

    setState(() {
      filteredNotes = result;
    });
    applySort();
  }

  void deleteNote(String id) async {
    await FirebaseService.deleteNote(id);
    loadNotes();
  }

  PopupMenuItem<NoteSortOption> _buildPopupItem(NoteSortOption value, String text) {
    final isSelected = _sortOption == value;
    return PopupMenuItem<NoteSortOption>(
      value: value,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.blue : AppColor.textPrimary(context),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
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

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColor.isDark(context)
                  ? [AppColor.darkSurface, AppColor.darkCard]
                  : [AppColor.gradien2, AppColor.gradien1],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Catatan Saya",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Simpan dan kelola ide Anda",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                  PopupMenuButton<NoteSortOption>(
                    icon: const Icon(Icons.sort, color: Colors.white),
                    onSelected: (NoteSortOption result) {
                      setState(() {
                        _sortOption = result;
                      });
                      applySort();
                      PreferenceHandler().setNoteSort(result.name);
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<NoteSortOption>>[
                      _buildPopupItem(NoteSortOption.titleAsc, 'Abjad (A-Z)'),
                      _buildPopupItem(NoteSortOption.dateAsc, 'Tanggal Terawal'),
                      _buildPopupItem(NoteSortOption.dateDesc, 'Tanggal Terakhir'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: AppColor.searchBox(context),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowColor(context),
                    blurRadius: 2,
                    spreadRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: searchNotes,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(color: AppColor.textPrimary(context)),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: "Cari catatan Anda...",
                  hintStyle: TextStyle(color: AppColor.textHint(context)),
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
            ),
          ),

          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 80,
                          color: AppColor.textHint(context).withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada catatan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textHint(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tekan tombol + untuk membuat catatan baru",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColor.textHint(context).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];

                return InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNoteScreen(note: note),
                      ),
                    );
                    loadNotes();
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColor.textHint(context),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              () {
                                try {
                                  final dt = DateFormat('yyyy-MM-dd HH:mm').parse(note.date);
                                  return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(dt);
                                } catch (e) {
                                  return note.date;
                                }
                              }(),
                              style: TextStyle(
                                color: AppColor.textHint(context).withOpacity(0.6),
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
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
