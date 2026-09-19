// 💡 HINT بالعربي:
// دي البلاغات أو الأوامر (Events) اللي شاشات الـ UI هتبعتها لمركز العمليات (AuthBloc).
// كل الأوامر بتورث من الكلاس الرئيسي AuthEvent عشان البلوك يقدر يستقبلها في مسبار واحد.
// بعض الأوامر بتكون فاضية (مجرد ضغطة زرار)، وبعضها بياخد بيانات معاه (زي الإيميل والباسورد) عشان يوصلها للسيرفر.

import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

// 1️⃣ أمر التهيئة والبدء: بيبعت أول ما التطبيق يفتح عشان يفحص هل فيه مستخدم مسجل دخول ولا لأ
class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

// 2️⃣ أمر إرسال إيميل التفعيل: بيبعت لما المستخدم يطلب إعادة إرسال رابط التحقق
class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

// 3️⃣ أمر تسجيل الدخول: بياخد معاه الإيميل والباسورد اللي انكتبوا في الشاشة عشان يبعتهم للبلوك
class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

// 4️⃣ أمر إنشاء حساب جديد: بياخد الإيميل والباسورد الجداد ويروح بيهم لفايربيز
class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister(this.email, this.password);
}

// 5️⃣ أمر الانتقال لشاشة التسجيل: بيبعت لما المستخدم يدوس على زرار "معنديش حساب وعايز أسجل"
class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

// 6️⃣ أمر نسيان الباسورد: بياخد الإيميل (اختياري) عشان يبعت عليه رابط إعادة تعيين الباسورد
class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  final String? code;         
  final String? newPassword;  

  const AuthEventForgotPassword({
    this.email,
    this.code,
    this.newPassword,
  });
}


// 7️⃣ أمر تسجيل الخروج: بيبعت لما المستخدم يدوس على Log out من القائمة
class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

