import 'package:firebase_test/sevices/auth/bloc/auth_bloc.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:firebase_test/enum/menue_action.dart';
import 'package:firebase_test/sevices/auth/auth_services.dart';
import 'package:firebase_test/utilies/dialogs/log_out_dialog.dart';
// شرح بالعربي: استيراد كود السيكوال والفايرستور معاً لتشغيل الشاشات والخدمات بالتوازي
import 'package:firebase_test/sevices/curd/notes_services.dart';
import 'package:firebase_test/sevices/cloud/cloud_note.dart';
import 'package:firebase_test/sevices/cloud/fire_base_cloud_storage.dart';
import 'package:firebase_test/views/notes/notes_list_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // شرح بالعربي: تعريف كلاسات الخدمات المحلية والسحابية بالحروف الكابيتال الصحيحة وبالأندر سكور
  late final NotesServices _notesService;
  late final FirebaseCloudStorage _cloudStorage;

  // شرح بالعربي: جلب بريد المستخدم الحالي لتمريره عند جلب البيانات
  String get userEmail => AuthService.firebase().currentUser!.email;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    // شرح بالعربي: تهيئة المحركين معاً داخل دالة الـ initState بدون حروف s زائدة في اسم الكلاس
    _notesService = NotesServices();
    _cloudStorage = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.of(context).pushNamed('/new-note/');
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  // 👇 1. بنخزن الـ Bloc في متغير مستقل هنا قبل الـ await والـ context ما يتأثروا
                  final authBloc = context.read<AuthBloc>();

                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    // 👇 2. بنادي على المتغير مباشرة من غير ما نستخدم الـ context تاني
                    authBloc.add(const AuthEventLogOut());
                  }
                  break;

                /* 
💡 كود الخروج والتوجيه القديم بتاع الـ SQLite (محفوظ كـ Template):
case MenuAction.logout:
  final shouldLogout = await showLogOutDialog(context);
  if (shouldLogout) {
    await AuthService.firebase().signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login/',
      (route) => false,
    );
  }
  break;
*/
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          ),
        ],
      ),
      // -----------------------------------------------------------------------------------
      // شرح بالعربي: هنا الـ body مصمم بشكل ذكي لعرض الـ CloudNotesListView السحابي مباشرة باستخدام الـ Stream السحابي
      // إذا أردت مستقبلاً العودة للـ SQLite، فقط قم باستبدال الـ Stream والـ Builder بكود الـ SQLite القديم المخزن أدناه كـ تعليق (Template)
      // -----------------------------------------------------------------------------------
      body: StreamBuilder(
        stream: _cloudStorage.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return CloudNotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _cloudStorage.deleteNote(documentId: note.documentId);
                  },
                  onTap: (note) {
                    Navigator.of(
                      context,
                    ).pushNamed('/new-note/', arguments: note);
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

/*
💡 شرح بالعربي: كود الـ SQLite الاحتياطي (Local Template) للرجوع إليه في أي وقت:
FutureBuilder(
  future: _notesService.getOrCreateUser(email: userEmail),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return StreamBuilder(
        stream: _notesService.allNotes,
        builder: (context, snapshot) { ... }
      );
    } else { return const CircularProgressIndicator(); }
  }
)
*/
