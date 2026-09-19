// ignore_for_file: use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test/firebase_options.dart';
import 'package:firebase_test/sevices/auth/auth_expection_all.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_bloc.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_event.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_state.dart';
import 'package:firebase_test/utilies/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context: context, text: 'Weak password');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(
              context: context,
              text: 'Email is already in use',
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context: context, text: 'Failed to register');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context: context, text: 'Invalid email');
          }
        }
      },
      child: Scaffold(
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
                          context.read<AuthBloc>().add(
                            AuthEventRegister(email, password),
                          );
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
                              context.read<AuthBloc>().add(
                                const AuthEventLogOut(), // 👈 دي اللي هترجعك لشاشة الـ Sign In عن طريق الـ Bloc
                              );
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
      ),
    );
  }
}
