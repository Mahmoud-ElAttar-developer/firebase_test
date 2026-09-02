// ignore_for_file: use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test/firebase_options.dart';
import 'package:firebase_test/sevices/auth/auth_expection_all.dart'
   ;
import 'package:firebase_test/sevices/auth/auth_services.dart';
import 'package:firebase_test/utilies/show_error_dialog.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // create a controller for the email and password fields
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password =
      TextEditingController(); // شيلنا الـ late والـ initState

  // Create the controllers in the initState method.
  // @override
  // void initState() {
  //   super.initState();
  //   _email = TextEditingController();
  //   _password = TextEditingController();
  // }

  // Clean up the controllers when the widget is disposed.
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),

        // FutureBuilder will only rebuild if the connection state changes.
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Email field
                    TextField(
                      decoration: const InputDecoration(hintText: 'Email'),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    // Password field
                    TextField(
                      decoration: const InputDecoration(hintText: 'Password'),
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                    ),

                    // Register button
                    TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;

                        try {
                          await AuthService.firebase()
                              .signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              );

                          final user = AuthService.firebase().currentUser;

                          // تأمين الـ BuildContext قبل التوجيه لشاشة أخرى
                          if (!mounted) return;

                          if (user?.isEmailVerified ?? false) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/notes/',
                              (route) => false,
                            );
                          } else {
                            if (!mounted) return;
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/verify-email/',
                              (route) => false,
                            );
                          }
                        } on UserNotFoundAuthException {
                          if (mounted) {
                            await showErrorDialog(
                              context,
                              'هذا المستخدم غير مسجل لدينا.',
                            );
                          }
                        } on WrongPasswordAuthException {
                          if (mounted) {
                            await showErrorDialog(
                              context,
                              'كلمة المرور غير صحيحة.',
                            );
                          }
                        } on InvalidEmailAuthException {
                          if (mounted) {
                            await showErrorDialog(
                              context,
                              'صيغة البريد الإلكتروني غير صالحة.',
                            );
                          }
                        } on GenericAuthException {
                          if (mounted) {
                            await showErrorDialog(
                              context,
                              'حدث خطأ في عملية المصادقة.',
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            await showErrorDialog(
                              context,
                              'حدث خطأ غير متوقع: ${e.toString()}',
                            );
                          }
                        }
                      },

                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'not register yet ? ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/register/',
                            ); // تحويل الـ register إلى الـ regiester
                          },
                          child: Text(
                            'register',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );

            default:
              return Text('Loading...');
          }
        },
      ),
    );
  }
}
