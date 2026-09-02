// ignore_for_file: use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test/firebase_options.dart';
import 'package:firebase_test/sevices/auth/auth_expection_all.dart';
import 'package:firebase_test/sevices/auth/auth_services.dart';
import 'package:firebase_test/utilies/show_error_dialog.dart';
import 'package:flutter/material.dart';

class RegiesterView extends StatefulWidget {
  const RegiesterView({super.key});

  @override
  State<RegiesterView> createState() => _RegiesterViewState();
}

class _RegiesterViewState extends State<RegiesterView> {
  // create a controller for the email and password fields
  // تعريف البناء المباشر بدون late وبدونinitState
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  // Create the controllers in the initState method.
  // @override
  // void initState() {
  //   super.initState();
  //   _name = TextEditingController();
  //   _email = TextEditingController();
  //   _password = TextEditingController();
  // }

  // Clean up the controllers when the widget is disposed.
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                    // Name field
                    TextField(
                      decoration: const InputDecoration(hintText: 'Name'),
                      controller: _name,
                    ),
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
                              .signUpWithEmailAndPassword(
                                email: email,
                                password: password,
                              );

                          await AuthService.firebase().sendEmailVerification();

                          if (!mounted) return;

                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/verify-email/',
                            (route) => false,
                          );
                        } on WeakPasswordAuthException {
                          if (mounted) {
                            await showErrorDialog(
                              context,
                              'The password is too weak.',
                            );
                          }
                        } on EmailAlreadyInUseAuthException {
                          if (mounted) {
                            await showErrorDialog(
                              context,
                              'The email is already in use.',
                            );
                          }
                        } on InvalidEmailAuthException {
                          if (mounted) {
                            await showErrorDialog(
                              context,
                              'Invalid email address.',
                            );
                          }
                        } on GenericAuthException {
                          if (mounted) {
                            await showErrorDialog(
                              context,
                              'Failed to register.',
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            await showErrorDialog(
                              context,
                              'Error: ${e.toString()}',
                            );
                          }
                        }
                      },

                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'already register? ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login/');
                          },
                          child: Text(
                            'login',
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
