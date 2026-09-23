import 'package:firebase_test/extintions/buildcontext/loc.dart';
import 'package:firebase_test/utilies/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.delete,
    content: context.loc.delete_note_prompt,
    optionsBuilder: () => {
      context.loc.cancel: false,
       context.loc.yes: true
       },
  ).then((value) => value ?? false);
}
