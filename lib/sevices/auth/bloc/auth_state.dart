// 💡 HINT بالعربي:
// دي التقارير الفنية (States) اللي مركز العمليات هيبعتها للـ UI بتاع الـ Authentication.
// كل الحالات بتورث من الكلاس الرئيسي AuthState، وكل حالة بتعرف الشاشة اللي الموبايل واقف عليها.
// الميزة هنا إن كل الحالات شايلة متغير (isLoading) عشان نتحكم في دايرة التحميل في أي شاشة بسهولة،
// وفيها (loadingText) عشان لو عايزين نكتب نص مخصص للمستخدم وهو مستني (زي: "جاري تسجيل الدخول...").

import 'package:firebase_test/sevices/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState  extends Equatable {
  final bool isLoading;
  final String? loadingText;

  const AuthState({
    required this.isLoading, 
    this.loadingText = 'Please wait a moment',
  });
   @override
  List<Object?> get props => [isLoading, loadingText];
}

// 1️⃣ حالة البداية: التطبيق لسه بيفتح وبيفحص السيرفر
class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required super.isLoading});
}

// 2️⃣ حالة التسجيل: المستخدم واقف في شاشة الـ Register وبيتخلق له حساب
class AuthStateRegistering extends AuthState {
  final Exception? exception; // لو حصل خطأ أثناء التسجيل يظهر هنا
  const AuthStateRegistering({
    required this.exception,
    required super.isLoading,
  });
   @override
  List<Object?> get props => [exception, isLoading, loadingText];
}

// 3️⃣ حالة نسيان الباسورد: شاشة استعادة الحساب وإرسال إيميل التعيين
class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail; // بتتحول لـ true أول ما الإيميل يتبعت فعلاً
  const AuthStateForgotPassword({
    required this.exception,
    required this.hasSentEmail,
    required super.isLoading,
  });
   @override
  List<Object?> get props => [exception, isLoading, loadingText];
}

// 4️⃣ حالة الدخول الناجح: المستخدم جوه التطبيق ومعانا بياناته (user)
class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required this.user, required super.isLoading});
  @override
  List<Object?> get props => [user, isLoading, loadingText];
}

// 5️⃣ حالة الحساب المعلق: الحساب اتعمل بس محتاج تفعيل من الإيميل أولاً
class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required super.isLoading});
}

// 6️⃣ حالة الخروج: المستخدم بره التطبيق تماماً (شاشة الـ Login)

// 💡 HINT بالعربي:
// هنا عدلنا كلاس الـ AuthStateLoggedOut عشان يتوافق مع التحديثات الجديدة لـ Dart و Equatable.
// شيلنا الـ Mixin وعملنا الـ override لـ props بشكل مباشر ونظيف جداً،
// وبكدة كل الخطوط الحمراء هتختفي تماماً والملف هيبقى سليم 100%!

class AuthStateLoggedOut extends AuthState {
  final Exception? exception;

  const AuthStateLoggedOut({
    required this.exception,
    required super.isLoading,
    super.loadingText = null,
  });

  // 👇 الـ Props المظبوطة للـ Equatable عشان المقارنة تشتغل صح بدون Mixin مكعبل
   @override
  List<Object?> get props => [exception, isLoading, loadingText];
}

// class AuthStateLoggedOutFailure extends AuthState {
//   final Exception? exception;

//   const AuthStateLoggedOutFailure({
//     required this.exception,
//     required super.isLoading,
//     super.loadingText = null,
//   });

//   // 👇 الـ Props المظبوطة للـ Equatable عشان المقارنة تشتغل صح بدون Mixin مكعبل
//   List<Object?> get props => [exception, isLoading];
// }