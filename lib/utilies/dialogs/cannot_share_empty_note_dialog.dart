// 💡 HINT بالعربي:
// الديالوج ده وظيفته حماية وتنبيه للمستخدم. 
// لما المستخدم يضغط على زرار الـ Share والنوت تكون لسه فاضية ومفيهاش أي نص مكتوب، 
// بنطلع له الصندوق ده يقوله: "ما ينفعش تشارك ملحوظة فاضية يا فنان!".
// الميزة هنا إنه بيعتمد على الـ generic_dialog اللي أنت عامله قبل كده فبيطلع شكله متناسق مع باقي ديايلوجات التطبيق.

import 'package:firebase_test/extintions/buildcontext/loc.dart';
import 'package:firebase_test/utilies/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.sharing,
    content: context.loc.cannot_share_empty_note_prompt,
    optionsBuilder: () => {
      context.loc.ok: null, // بيقفل الديالوج لما يضغط موافق
    },
  );
}
