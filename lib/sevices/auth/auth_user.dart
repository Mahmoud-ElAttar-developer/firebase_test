import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  // متغير ثابت يحفظ حالة تفعيل البريد الإلكتروني
  final bool isEmailVerified;

  // الكونستركتور الأساسي والثابت للكلاس
  const AuthUser(this.isEmailVerified);

  // دالة المصنع (factory) لتحويل مستخدم Firebase إلى AuthUser الخاص بنا
  // الـ factory (المصنع في السطر 9): يعطيك مرونة وذكاء أعلى؛ المصنع لا يقوم بإنشاء
  // كائن بشكل عشوائي، بل يمكنك كتابة
  // كود بداخله ليقوم بـ (تحليل البيانات،
  // أو قراءة متغيرات من كلاس آخر مثل فيربيز،
  // أو حتى إرجاع كائن قديم تم إنشاؤه 
  //مسبقاً من الذاكرة لتوفير المساحة).
  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}
