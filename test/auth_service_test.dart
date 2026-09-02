import 'package:firebase_test/sevices/auth/auth_provider.dart';
import 'package:firebase_test/sevices/auth/auth_user.dart';
// نقوم باستدعاء ملف المستخدم الفعلي لنفحصه هنا خارج مجلد lib

void main() {}

class MockAuthProvider implements AuthProvider {
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  AuthUser? get currentUser => throw UnimplementedError();

  @override
  Future<void> initialize() {
    throw UnimplementedError();
  }

  @override
  void dispose() {}

  @override
  bool get isLoggedIn => throw UnimplementedError();

  Future<AuthUser> logIn({required String email, required String password}) =>
      throw UnimplementedError();

  Future<void> logOut() => throw UnimplementedError();

  @override
  Future<void> sendEmailVerification() => throw UnimplementedError();

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> verifyEmail({required String email, required String code}) {
    throw UnimplementedError();
  }
}

@override
Future<void> resetPassword({
  required String email,
  required String code,
  required String newPassword,
}) {
  throw UnimplementedError();
}

@override
Future<void> sendEmailVerification() {
  throw UnimplementedError();
}

@override
Future<void> signInWithEmailAndPassword({
  required String email,
  required String password,
}) {
  throw UnimplementedError();
}

@override
Future<void> signOut() {
  throw UnimplementedError();
}

@override
Future<void> signUpWithEmailAndPassword({
  required String email,
  required String password,
}) {
  throw UnimplementedError();
}

@override
Future<void> verifyEmail({required String email, required String code}) {
  throw UnimplementedError();
}

  // ملحوظة: ستحتاج أيضاً لإضافة بقية الدوال مثل logIn و logOut
  // بنفس الطريقة إذا طلبها البرنامج منك (عبر وضع throw UnimplementedError).

