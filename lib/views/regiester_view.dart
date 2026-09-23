// ignore_for_file: use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test/extintions/buildcontext/loc.dart';
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
            await showErrorDialog(context: context, text: context.loc.register_error_weak_password);
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(
              context: context,
              text: context.loc.register_error_email_already_in_use,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context: context, text: context.loc.register_error_generic);
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context: context, text: context.loc.register_error_invalid_email);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.loc.register)),
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            context.loc.register_view_prompt,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          // Name field
                          TextField(
                            decoration:  InputDecoration(hintText: context.loc.name_text_field_placeholder),
                            controller: _name,
                          ),
                          // Email field
                          TextField(
                            decoration:  InputDecoration(hintText: context.loc.email_text_field_placeholder),
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          // Password field
                          TextField(
                            decoration:  InputDecoration(hintText: context.loc.password_text_field_placeholder),
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
                             context.loc.register,
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Text(
                              //   context.loc.register_view_already_registered,
                              //   style: TextStyle(color: Colors.grey),
                              // ),
                              TextButton(
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    const AuthEventLogOut(), // 👈 دي اللي هترجعك لشاشة الـ Sign In عن طريق الـ Bloc
                                  );
                                },
                                child: Text(
                                 context.loc.register_view_already_registered,
                                  style: TextStyle(color: Colors.blue,),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );

              default:
                return Text(context.loc.register_view_prompt);
            }
          },
        ),
      ),
    );
  }
}
