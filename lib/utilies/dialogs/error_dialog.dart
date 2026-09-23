import 'package:firebase_test/extintions/buildcontext/loc.dart';
import 'package:firebase_test/utilies/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog({
  required BuildContext context,
  required String text,
}) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.generic_error_prompt,
    content: text,
    optionsBuilder: () => {
      context.loc.ok: null, // بيقفل الديالوج لما يضغط موافق
    },
  );
}
