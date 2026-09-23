import 'package:firebase_test/extintions/buildcontext/loc.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_bloc.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_event.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_state.dart';
import 'package:firebase_test/utilies/dialogs/error_dialog.dart';
import 'package:firebase_test/utilies/dialogs/password_reset_email_sent_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            if (!context.mounted) return;
            await showErrorDialog(
              context: context,
              text:
                 context.loc.login_error_cannot_find_user, // 🛑 تم تصليحها هنا بيمرر القيم مباشرة بدون كلمات context: أو text:
            );
          }
        }
      },

      child: Scaffold(
        appBar: AppBar(title: Text(context.loc.forgot_password)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                 Text(
                 context.loc.forgot_password_view_prompt,
                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: true,
                  controller: _controller,
                  decoration:  InputDecoration(
                    hintText: context.loc.email_text_field_placeholder,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final email = _controller.text;
                    context.read<AuthBloc>().add(
                      AuthEventForgotPassword(email: email),
                    );
                  },
                  child:  Text(context.loc.forgot_password_view_send_me_link),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: Text(context.loc.logout_button),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
