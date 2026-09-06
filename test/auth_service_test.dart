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
    // --------------------------------------------------------------------------------

    // 1. فحص البداية
    test('Should not be initialized to begin with', () {
      final freshProvider = MockAuthProvider();
      expect(freshProvider.isInitialized, false);
    });

    // 2. فحص الخروج قبل التهيئة
    test('Cannot log out if not initialized', () {
      final freshProvider = MockAuthProvider();
      expect(
        () => freshProvider.signOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    // 3. فحص أن المستخدم فارغ بعد التهيئة مباشرة
    test('User should be null after initialization', () async {
      await provider.initialize();
      expect(provider.currentUser, isNull);
    });

    // 4. فحص وقت التهيئة (Timeout)
    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      }, 
      timeout: const Timeout(Duration(seconds: 2)),
    );

    // 5. فحص إنشاء الحساب الشامل وتمرير الأخطاء والنجاح
    test('Create user should delegate to login function', () async {
      // أ) فحص الإيميل الخاطئ
      expect(
        () => provider.signUpWithEmailAndPassword(
          email: 'error@example.com',
          password: 'anypassword',
        ),
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      // ب) فحص الباسورد الخاطئ
      expect(
        () => provider.signUpWithEmailAndPassword(
          email: 'someone@bar.com',
          password: 'wrong',
        ),
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );

      // ج) فحص نجاح إنشاء الحساب
      final user = await provider.signUpWithEmailAndPassword(
        email: 'foo',
        password: 'bar',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, true);
    });

    // 6. فحص تفعيل البريد الإلكتروني للمستخدم الحالي
    test('Logged in user should be able to get verified', () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    // 7. فحص دورة تسجيل الخروج ثم الدخول مجدداً باستخدام signInWithEmailAndPassword
    test('Should be able to log out and log in again', () async {
      await provider.signOut();
      expect(provider.currentUser, isNull);

      final user = await provider.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'test',
      );
      expect(user, isNotNull);
      expect(provider.currentUser, user);
    });
    // --------------------------------------------------------------------------------
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
    _user = null;
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

    const user = AuthUser(isEmailVerified: true, email: '');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> sendEmailVerification() {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotLoggedInAuthException();
    const user2 = AuthUser(isEmailVerified: true, email: '');
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
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();

    // الشروط الناقصة التي يبحث عنها التست ليتحول للون الأخضر
    if (email == 'error@example.com') throw UserNotFoundAuthException();
    if (password == 'wrong') throw WrongPasswordAuthException();

    await Future.delayed(const Duration(seconds: 1));
    return signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> verifyEmail({required String email, required String code}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    if (!isInitialized) throw NotInitializedException();
    _user = null; // نقوم بتصفير المستخدم لتسجيل الخروج بنجاح
  }
}
  // ملحوظة: ستحتاج أيضاً لإضافة بقية الدوال مثل logIn و logOut
  // بنفس الطريقة إذا طلبها البرنامج منك (عبر وضع throw UnimplementedError)