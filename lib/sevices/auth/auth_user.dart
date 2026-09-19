import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  // التعديل هنا: جعل الـ email يقبل أن يكون فارغاً String? ليطابق Firebase
  final String email;
  final bool isEmailVerified;

  const AuthUser({
    required this.email,
    required this.isEmailVerified,
    required this.id,
  });

  factory AuthUser.fromFirebase(User user) =>
      AuthUser(email: user.email!, isEmailVerified: user.emailVerified, id: '');
}
