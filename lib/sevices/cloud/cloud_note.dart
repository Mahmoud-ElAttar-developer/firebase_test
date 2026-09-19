import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_test/sevices/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';


// وظيفته: هو المترجم أو الجسر بين لغة Firebase ولغة Dart.
// شرح بالعربي: هذا الكلاس يمثل هيكل الملاحظة السحابية (Model) المخزنة في الـ Firestore
@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  // شرح بالعربي: هذا الكونستركتور يأخذ لقطة البيانات القادمة من Firestore (Snapshot)
  // ويستخرج منها المعرّفات والنصوص باستخدام الثوابت (Constants) لضمان عدم وجود أخطاء إملائية
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      ownerUserId = snapshot.data()[ownerUserIdFieldName],
      text = snapshot.data()[textFieldName] as String;
}
