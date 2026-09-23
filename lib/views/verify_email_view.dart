import 'package:firebase_test/extintions/buildcontext/loc.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_bloc.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.loc.verify_email_view_prompt,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              Text(
                context.loc.verify_email_send_email_verification,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              TextButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(
                    const AuthEventSendEmailVerification(),
                  );
                },
                child:  Text(
                  context.loc.verify_email_send_email_verification,
                  style: TextStyle(color: Colors.blue, fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: Text(
                  context.loc.logout_button,
                  style: TextStyle(color: Colors.blue, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
