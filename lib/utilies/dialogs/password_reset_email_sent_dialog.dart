import 'package:firebase_test/extintions/buildcontext/loc.dart';
import 'package:firebase_test/utilies/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.password_reset,
    content: context.loc.password_reset_dialog_prompt,
    optionsBuilder: () => {
      context.loc.ok: null, // بيقفل الديالوج لما يضغط موافق
    },
  );
}
