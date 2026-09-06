// ignore_for_file: use_build_context_synchronously

import 'package:firebase_test/enum/menue_action.dart';
import 'package:firebase_test/sevices/auth/auth_services.dart';
import 'package:firebase_test/sevices/curd/notes_services.dart';
import 'package:flutter/material.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesServices _notesService;

  // الـ Getter الذي استنتجناه في الخطوة السابقة لجلب بريد المستخدم الحالي
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesServices(); // إنشاء كائن من خدمة الملاحظات
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    // استخدام الخدمة النظيفة بتاعتك بدلاً من الفايربيز المباشر
                    await AuthService.firebase().signOut();

                    if (!mounted) return;

                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login/', (route) => false);
                  }
                  break;
              }
            },

            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: MenuAction.logout,
                  child: const Text('Logout'),
                ),
              ];
            },
          ),
        ],
        title: const Text('Notes'),
      ),
      // بناء وإدارة بث الملاحظات الحية وعرضها فوراً في القائمة الرئيسية مع تغطية كل حالات البث
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    // التعديل هنا: دمج كل الحالات النشطة والمستمرة للبث لضمان قراءة الداتا دائماً
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                    default:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;

                        // فحص إضافي: لو القائمة رجعت فارغة نطبع نص يوضح ذلك بدل الشاشة البيضاء
                        if (allNotes.isEmpty) {
                          return const Center(
                            child: Text(
                              'No notes found yet. Press + to add one!',
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: allNotes.length,
                          itemBuilder: (context, index) {
                            final note = allNotes[index];
                            return ListTile(title: Text(note.text));
                          },
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                  }
                },
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}



// دالة بناء وعرض نافذة تنبيه للمستخدم لتأكيد رغبته في تسجيل الخروج من التطبيق أم لا
Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
