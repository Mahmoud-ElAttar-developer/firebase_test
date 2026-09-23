import 'package:firebase_test/extintions/buildcontext/loc.dart';
import 'package:firebase_test/utilies/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.logout_dialog_prompt,
    content: context.loc.logout_button,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.yes: true
    },
  ).then(
    (value) => value ?? false,
  );
}
