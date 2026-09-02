import 'package:firebase_test/sevices/auth/auth_expection_all.dart';
import 'package:firebase_test/sevices/auth/auth_provider.dart';
import 'package:firebase_test/sevices/auth/auth_user.dart';
// نقوم باستدعاء ملف المستخدم الفعلي لنفحصه هنا خارج مجلد lib

void main() {}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isIntialized = false;
  bool get isInitialized => _isIntialized;

  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();

    // أضفنا كلمة await وكلمة return لتأخير العملية ثانية واحدة ثم إرجاع النتيجة
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isIntialized = true;
  }

  @override
  void dispose() {}

  @override
  bool get isLoggedIn => throw UnimplementedError();

  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'error@example.com' && password == 'error') throw UserNotFoundAuthException();
     
    if (email == 'wrong@example.com' && password == 'wrong')throw WrongPasswordAuthException();
      
    const user = AuthUser(isEmailVerified: true);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> sendEmailVerification() {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotLoggedInAuthException();
    const user2 = AuthUser(isEmailVerified: true);
    _user = user2;
    return Future.value();
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
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
    return Future.value();
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




  // ملحوظة: ستحتاج أيضاً لإضافة بقية الدوال مثل logIn و logOut
  // بنفس الطريقة إذا طلبها البرنامج منك (عبر وضع throw UnimplementedError).