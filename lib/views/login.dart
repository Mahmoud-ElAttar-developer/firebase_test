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
  // CloseDialog? _closeDialogHandle;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        // 1️⃣ فحص حالة تسجيل الخروج لالتقاط الأخطاء المتدفقة من الـ Bloc
        if (state is AuthStateLoggedOut) {
          // final closeDialog = _closeDialogHandle;

          // if (!state.isLoading && closeDialog != null) {
          //   closeDialog();
          //   _closeDialogHandle = null;
          // } else if (state.isLoading && closeDialog == null) {
          //   _closeDialogHandle = showLoadingDialog(
          //     context: context,
          //     text: 'Loading...',
          //   );
          // }

          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context: context,
              text: context.loc.login_error_cannot_find_user,
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
              context: context,
              text: context.loc.login_error_wrong_credentials,
            );
          } else if (state.exception is GenericAuthException) {
            // 🛑 تم تصليحها هنا بيمرر القيم مباشرة بدون كلمات context: أو text:
            await showErrorDialog(
              context: context,
              text: context.loc.login_error_auth_error,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.loc.login)),
        body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),

          // FutureBuilder will only rebuild if the connection state changes.
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          context.loc.login_view_prompt,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Email field
                        TextField(
                          decoration: InputDecoration(
                            hintText: context.loc.email_text_field_placeholder,
                          ),
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        // Password field
                        TextField(
                          decoration: InputDecoration(
                            hintText:
                                context.loc.password_text_field_placeholder,
                          ),
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                        ),

                        // login button
                        TextButton(
                          onPressed: () async {
                            context.read<AuthBloc>().add(
                              AuthEventLogIn(_email.text, _password.text),
                            );
                            // try {
                            //   await AuthService.firebase()
                            //       .signInWithEmailAndPassword(
                            //         email: email,
                            //         password: password,
                            //       );
                            //   final user = AuthService.firebase().currentUser;
                            //   // تأمين الـ BuildContext قبل التوجيه لشاشة أخرى
                            //   if (!mounted) return;
                            //   if (user?.isEmailVerified ?? false) {
                            //     Navigator.of(context).pushNamedAndRemoveUntil(
                            //       '/notes/',
                            //       (route) => false,
                            //     );
                            //   } else {
                            //     if (!mounted) return;
                            //     Navigator.of(context).pushNamedAndRemoveUntil(
                            //       '/verify-email/',
                            //       (route) => false,
                            //     );
                            //   }
                            // } on UserNotFoundAuthException {
                            //   if (mounted) {
                            //     await showErrorDialog(
                            //       context: context,
                            //       text: 'User not found.',
                            //     );
                            //   }
                            // } on WrongPasswordAuthException {
                            //   if (mounted) {
                            //     await showErrorDialog(
                            //       context: context,
                            //       text: 'Wrong credentials.',
                            //     );
                            //   }
                            // } on InvalidEmailAuthException {
                            //   if (mounted) {
                            //     await showErrorDialog(
                            //       context: context,
                            //       text: 'Invalid email address.',
                            //     );
                            //   }
                            // } on GenericAuthException {
                            //   if (mounted) {
                            //     await showErrorDialog(
                            //       context: context,
                            //       text: 'Authentication error.',
                            //     );
                            //   }
                            // }
                            // catch (e) {
                            //   if (mounted) {
                            //     await showErrorDialog(
                            //       context: context,
                            //       text:
                            //           'An unexpected error occurred: ${e.toString()}',
                            //     );
                            //   }
                            // }
                          },

                          child: Text(
                            context.loc.login,
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              const AuthEventForgotPassword(),
                            );
                          },
                          child: Text(
                            context.loc.verify_email_send_email_verification,
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Text(
                            //   context.loc.login_view_not_registered_yet,
                            //   style: TextStyle(color: Colors.grey),
                            // ),
                            TextButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                  const AuthEventShouldRegister(),
                                );
                              },
                              child: Text(
                                context.loc.login_view_not_registered_yet,
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

              default:
                return Text(context.loc.login_view_prompt);
            }
          },
        ),
      ),
    );
  }
}
