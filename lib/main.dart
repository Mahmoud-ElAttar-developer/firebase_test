import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test/firebase_options.dart';
import 'package:firebase_test/views/login.dart';
import 'package:firebase_test/views/notes/new_views.dart';
import 'package:firebase_test/views/notes/notes_view.dart';
import 'package:firebase_test/views/regiester_view.dart';
import 'package:firebase_test/views/verify_email_view.dart'; // استدعاء صفحة التأكيد
import 'package:flutter/material.dart';
import 'sevices/auth/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      title: 'Firebase Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegiesterView(),
        '/notes/': (context) => const NotesView(),
        '/verify-email/': (context) => const VerifyEmailView(),
        '/new-note/': (context) => const NewNoteView(),
      },

      // الـ home هنا هو اللي بيتحكم هيعرض أنهي صفحة كاملة ومستقلة
      home: FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user?.isEmailVerified ?? false) {
                return const NotesView();
              } else if (user == null) {
                return const LoginView();
              } else {
                return const VerifyEmailView();
              }
            default:
              return const Scaffold(body: Center(child: Text('Loading...')));
          }
        },
      ),
    ),
  );
}
