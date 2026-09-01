import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('An error occurred'), // عنوان النافذة
        content: Text(text), // نص الخطأ المتغير الذي يمرر للدالة
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pop(); // إغلاق النافذة عند الضغط على زر موافق
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
