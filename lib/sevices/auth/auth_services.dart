import 'auth_provider.dart';
import 'auth_user.dart';
import 'firebase_auth_provider.dart'; // استدعاء الموظف الفعلي لكي يجلس على الكرسي

class AuthService implements AuthProvider {
  // 1. تجهيز الكرسي ونوع الموظف الذي سيعمل داخل المكتب
  final AuthProvider provider;
  
  // 2. الكونستركتور الذي يستقبل الموظف
  const AuthService(this.provider);

  // 3. دالة سحرية (factory) تجعل التطبيق يفتح فرع فيربيز تلقائياً عند استدعائه
  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  // 4. الآن المكتب يستقبل طلبك ويمرره للموظف فوراً دون أن يتدخل في التفاصيل:
  
  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  bool get isLoggedIn => provider.isLoggedIn;

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) => provider.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) => provider.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

  @override
  Future<void> signOut() => provider.signOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) => provider.verifyEmail(
        email: email,
        code: code,
      );

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => provider.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );

  @override
  void dispose() => provider.dispose();
}
