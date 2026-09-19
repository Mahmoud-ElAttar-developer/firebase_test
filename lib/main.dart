import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test/firebase_options.dart';
import 'package:firebase_test/helpers/loading/loading_screen.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_bloc.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_event.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_state.dart';
import 'package:firebase_test/sevices/auth/firebase_auth_provider.dart';
import 'package:firebase_test/views/login.dart';
import 'package:firebase_test/views/notes/creat_update_note.dart';
import 'package:firebase_test/views/notes/notes_view.dart';
import 'package:firebase_test/views/regiester_view.dart';
import 'package:firebase_test/views/verify_email_view.dart'; // استدعاء صفحة التأكيد
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      title: 'Firebase Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      routes: {
        // '/login/': (context) => const LoginView(),
        // '/register/': (context) => const RegiesterView(),
        // '/notes/': (context) => const NotesView(),
        // '/verify-email/': (context) => const VerifyEmailView(),
        '/new-note/': (context) => const CreateUpdateNoteView(),
      },

      // الـ home هنا هو اللي بيتحكم هيعرض أنهي صفحة كاملة ومستقلة
      // 💡 HINT بالعربي:
      // هنا بنشغل الـ BlocProvider عشان يولد نسخة من الـ AuthBloc ويخليها متاحة للتطبيق كله.
      // وجواها بنستخدم الـ BlocConsumer الساحر اللي شرحناه؛
      // الـ listener بتاعه بيراقب لو الـ State اتغيرت وبقت محتاجة تحميل أو خروج،
      // والـ builder بيبني الشاشة المناسبة تلقائياً (NotesView لو مسجل دخول، LoginView لو بره، أو VerifyEmailView).
      // الـ FutureBuilder القديم بتاعك هتلاقيني سايبهولك تحت في الكومنتس عشان يفضل Template محتفظ بيه!
      home: BlocProvider<AuthBloc>(
        create: (context) =>
            AuthBloc(FirebaseAuthProvider())..add(const AuthEventInitialize()),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.isLoading) {
              LoadingScreen().show(
                context: context,
                text: state.loadingText ?? 'Please wait a moment',
              );
            } else {
              LoadingScreen().hide();
            }
          },

          builder: (context, state) {
            if (state is AuthStateLoggedIn) {
              return const NotesView();
            } else if (state is AuthStateNeedsVerification) {
              return const VerifyEmailView();
            } else if (state is AuthStateLoggedOut) {
              return const LoginView();
            } else if (state is AuthStateRegistering) {
              return const RegiesterView();
            } else {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    ),
  );
}

/* 
💡 الـ FutureBuilder القديم بتاع الـ SQLite (محفوظ كـ Template):
home: FutureBuilder(
  future: AuthService.firebase().initialize(),
  builder: (context, snapshot) {
    كود الفيو القديم بتاعك هيفضل محفوظ هنا بالكامل...
  },
)
*/
