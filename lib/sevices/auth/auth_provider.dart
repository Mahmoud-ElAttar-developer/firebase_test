import 'package:firebase_test/sevices/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendEmailVerification();

  Future<void> verifyEmail({required String email, required String code});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  bool get isLoggedIn;

  AuthUser? get currentUser;

  void dispose();

}
