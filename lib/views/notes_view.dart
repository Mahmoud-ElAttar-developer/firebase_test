// ignore_for_file: use_build_context_synchronously

import 'package:firebase_test/enum/menue_action.dart';
import 'package:firebase_test/sevices/auth/auth_services.dart';
import 'package:flutter/material.dart';

class NotesWidget extends StatefulWidget {
  const NotesWidget({super.key});

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    // استخدام الخدمة النظيفة بتاعتك بدلاً من الفايربيز المباشر
                    await AuthService.firebase().signOut();

                    if (!mounted) return;

                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
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
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then(
    (value) => value ?? false,
  ); // 👈 هذا السطر يحول القيمة من bool? إلى bool ويحل الخطأ
}
