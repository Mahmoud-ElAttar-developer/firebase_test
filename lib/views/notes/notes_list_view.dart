import 'package:flutter/material.dart';
import 'package:firebase_test/utilies/dialogs/delete_dialog.dart';
// شرح بالعربي: استيراد كود السيكوال والفايرستور معاً لتشغيل الكلاسين بالتوازي
import 'package:firebase_test/sevices/curd/notes_services.dart';
import 'package:firebase_test/sevices/cloud/cloud_note.dart';

// ------------------- أولاً: كلاس عرض ملاحظات السيكوال المحلي -------------------
typedef NoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          onTap: () => onTap(note),
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
          ),
        );
      },
    );
  }
}

// ------------------- ثانياً: كلاس عرض ملاحظات الفايرستور السحابي -------------------
// شرح بالعربي: تعريف الـ Callback الخاص بالملاحظات السحابية باستخدام CloudNote بدلاً من DatabaseNote
typedef CloudNoteCallback = void Function(CloudNote note);

class CloudNotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes; // شرح بالعربي: نستخدم Iterable هنا لأن الـ Firestore يرجع قائمة قابلة للتكرار مباشرة
  final CloudNoteCallback onDeleteNote;
  final CloudNoteCallback onTap;

  const CloudNotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index); // شرح بالعربي: جلب العنصر باستخدام elementAt لأن البيانات نوعها Iterable
        return ListTile(
          onTap: () => onTap(note),
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
          ),
        );
      },
    );
  }
}
