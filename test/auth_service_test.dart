import 'package:firebase_test/sevices/auth/auth_expection_all.dart';
import 'package:firebase_test/sevices/auth/auth_provider.dart';
import 'package:firebase_test/sevices/auth/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';
// نقوم باستدعاء ملف المستخدم الفعلي لنفحصه هنا خارج مجلد lib

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('signInWithEmailAndPassword', () async {
      await provider.initialize();
      final user = await provider.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'test',
      );
      expect(user.isEmailVerified, true);
    });
    test('signInWithEmailAndPassword with error', () async {
      await provider.initialize();
      try {
        await provider.signInWithEmailAndPassword(
          email: 'error@example.com',
          password: 'error',
        );
      } on UserNotFoundAuthException catch (e) {
        expect(e, isA<UserNotFoundAuthException>());
      }
    });
    test('signInWithEmailAndPassword with wrong password', () async {
      await provider.initialize();
      try {
        await provider.signInWithEmailAndPassword(
          email: 'wrong@example.com',
          password: 'wrong',
        );
      } on WrongPasswordAuthException catch (e) {
        expect(e, isA<WrongPasswordAuthException>());
      }
    });
    test('signUpWithEmailAndPassword', () async {
      await provider.initialize();
      final user = await provider.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'test',
      );
      expect(user.isEmailVerified, true);
    });
    test('signUpWithEmailAndPassword with error', () async {
      await provider.initialize();
      try {
        await provider.signUpWithEmailAndPassword(
          email: 'error@example.com',
          password: 'error',
        );
      } on UserNotFoundAuthException catch (e) {
        expect(e, isA<UserNotFoundAuthException>());
      }
    });
    test('signOut', () async {
      await provider.initialize();
      await provider.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'test',
      );
      await provider.signOut();
      expect(provider.currentUser, isNull);
    });
    test('sendEmailVerification', () async {
      await provider.initialize();
      await provider.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'test',
      );
      await provider.sendEmailVerification();
      expect(provider.currentUser?.isEmailVerified, true);
    });
// -----------------------------------------------------------------------------
        // 1. فحص: لا يمكن تسجيل الخروج إذا لم يتم تشغيل التهيئة
     test('Should not be able to sign out if not initialized', () {
      expect(
        provider.signOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    // 2. فحص: التأكد من عمل التهيئة بنجاح وتحويل المتغير لـ true
    test('Should be able to initialize', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    // 3. فحص: التأكد من إمكانية إنشاء حساب مستخدم جديد
    test('User should be able to create account', () async {
      await provider.initialize();
      final user = await provider.signUpWithEmailAndPassword(
        email: 'register@test.com',
        password: 'password123',
      );
      expect(user.isEmailVerified, false);
    });

    // 4. فحص: تسجيل الدخول بنجاح بحساب صحيح
    test('Should be able to sign in with valid user', () async {
      await provider.initialize();
      final user = await provider.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'test',
      );
      expect(provider.currentUser, isNotNull);
      expect(user.isEmailVerified, true);
    });

    // 5. فحص: فشل تسجيل الدخول بسبب إيميل غير موجود
    test('Sign in should fail with user-not-found', () async {
      await provider.initialize();
      expect(
        provider.signInWithEmailAndPassword(
          email: 'error@example.com',
          password: 'error',
        ),
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );
    });

    // 6. فحص: فشل تسجيل الدخول بسبب كلمة مرور خاطئة
    test('Sign in should fail with wrong-password', () async {
      await provider.initialize();
      expect(
        provider.signInWithEmailAndPassword(
          email: 'wrong@example.com',
          password: 'wrong',
        ),
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );
    });

    // 7. فحص: التأكد من إمكانية تسجيل الخروج بنجاح وعودة المستخدم لـ null
    test('User should be able to sign out', () async {
      await provider.initialize();
      await provider.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'test',
      );
      await provider.signOut();
      expect(provider.currentUser, isNull);
    });

  });

  

}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isIntialized = false;
  bool get isInitialized => _isIntialized;




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



  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'error@example.com' && password == 'error') throw UserNotFoundAuthException();
    if (email == 'wrong@example.com' && password == 'wrong') throw WrongPasswordAuthException();
    
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
  Future<void> signOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
    return Future.value();
  }

  @override
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    
    await Future.delayed(const Duration(seconds: 1));
    return signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }


  @override
  Future<void> verifyEmail({required String email, required String code}) {
    throw UnimplementedError();
  }
}




  // ملحوظة: ستحتاج أيضاً لإضافة بقية الدوال مثل logIn و logOut
  // بنفس الطريقة إذا طلبها البرنامج منك (عبر وضع throw UnimplementedError).