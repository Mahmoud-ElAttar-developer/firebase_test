import 'package:flutter/material.dart';

// دالة لإظهار الـ Loading Dialog وإرجاع دالة تانية لإغلاقه
typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10),
        Text(text), // النص الديناميكي (مثل: جاري تسجيل الدخول)
      ],
    ),
  );

  showDialog(
    context: context,
    barrierDismissible: false, // يمنع إغلاق الديالوج إذا ضغط المستخدم خارجه
    builder: (context) => dialog,
  );

  // إرجاع دالة الإغلاق ليتم استدعاؤها من الـ BlocListener لاحقاً
  return () => Navigator.of(context).pop();
}
