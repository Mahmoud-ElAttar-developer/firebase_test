import 'package:flutter/foundation.dart';

@immutable
abstract class AuthException implements Exception {}

// ===== أخطاء مشتركة (تحدث في الـ Login والـ Register) =====
class InvalidEmailAuthException implements AuthException {}

class NetworkRequestFailedAuthException implements AuthException {}

class TooManyRequestsAuthException implements AuthException {}

class ConnectionTimeoutAuthException implements AuthException {}

class OperationNotAllowedAuthException implements AuthException {}

class GenericAuthException implements AuthException {}

// ===== أخطاء خاصة بالـ Login فقط =====
class UserNotFoundAuthException implements AuthException {}

class WrongPasswordAuthException implements AuthException {}

class InvalidCredentialAuthException implements AuthException {}

class UserDisabledAuthException implements AuthException {}

class EmailNotVerifiedAuthException implements AuthException {}

class LogInCanceledAuthException implements AuthException {}

class UserNotLoggedInAuthException implements AuthException {}

// ===== أخطاء خاصة بالـ Register فقط =====
class EmailAlreadyInUseAuthException implements AuthException {}

class WeakPasswordAuthException implements AuthException {}

class ErrorSendingVerificationEmailAuthException implements AuthException {}

// ===== أخطاء خاصة بالـ Verify Email =====

// login expections

class WrongPasswordAuthExpection implements Exception {}

// register expections
class WeakPasswordAuthExpection implements Exception {}

class EmailAlreadyInUseAuthExpection implements Exception {}

class InvalidEmailAuthExpection implements Exception {}

// Generic expections


