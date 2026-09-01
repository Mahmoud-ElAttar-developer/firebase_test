import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test/firebase_options.dart';
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
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                          final user = FirebaseAuth.instance.currentUser;
                          await user?.sendEmailVerification();
                          if (!context.mounted) return;
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/verify-email/',
                            (route) => false,
                          );
                        } on FirebaseAuthException catch (e) {
                          if (!context.mounted) return;
                          if (e.code == 'weak-password') {
                            await showErrorDialog(
                              context,
                              'The password is too weak.',
                            );
                          } else if (e.code == 'email-already-in-use') {
                            await showErrorDialog(
                              context,
                              'The email is already in use by another account.',
                            );
                          } else if (e.code == 'invalid-email') {
                            await showErrorDialog(
                              context,
                              'The email address is badly formatted.',
                            );
                          } else {
                            await showErrorDialog(context, 'Error: ${e.code}');
                          }
                        } catch (e) {
                          await showErrorDialog(context, e.toString());
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
