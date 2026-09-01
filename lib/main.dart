import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test/firebase_options.dart';
import 'package:firebase_test/views/login.dart';
import 'package:firebase_test/views/notes_view.dart';
import 'package:firebase_test/views/regiester_view.dart';
import 'package:firebase_test/views/verify_email_view.dart'; // استدعاء صفحة التأكيد
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        '/notes/': (context) => const NotesWidget(),
        '/verify-email/': (context) => const VerifyEmailView(),
      },

      // الـ home هنا هو اللي بيتحكم هيعرض أنهي صفحة كاملة ومستقلة
      home: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user?.emailVerified ?? false) {
                // الـ ?? هو المفتاح الذي يحتاج للتأكيد عن طريق البريد الإلكتروني
                // الـ emailVerified هو المفتاح الذي يحتاج للتأكيد عن طريق البريد الإلكتروني
                return const NotesWidget(); // صفحة الهوم كاملة ومستقلة
              } else if (user == null) {
                return const LoginView(); // صفحة الهوم كاملة ومستقلة
              } else {
                return const VerifyEmailView(); // صفحة التأكيد كاملة ومستقلة
              }
            default:
              return const Scaffold(body: Center(child: Text('Loading...')));
          }
        },
      ),
    ),
  );
}
