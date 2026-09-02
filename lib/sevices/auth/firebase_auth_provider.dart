import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test/firebase_options.dart';
import 'package:firebase_test/sevices/auth/auth_expection_all.dart';
import 'auth_provider.dart';
import 'auth_user.dart';

class FirebaseAuthProvider implements AuthProvider {
  // Singleton pattern setup
  FirebaseAuthProvider._internal();
  static final FirebaseAuthProvider _instance = FirebaseAuthProvider._internal();
  factory FirebaseAuthProvider() => _instance;

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    }
    return null;
  }

  @override
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == 'user-disabled') {
        throw UserDisabledAuthException();
      } else if (e.code == 'too-many-requests') {
        throw TooManyRequestsAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  void dispose() {}
}














// import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
// import 'auth_exceptions.dart';
// import 'auth_provider.dart';
// import 'auth_user.dart';

// class FirebaseAuthProvider implements AuthProvider {
//   // Singleton pattern setup
//   FirebaseAuthProvider._internal();
//   static final FirebaseAuthProvider _instance = FirebaseAuthProvider._internal();
//   factory FirebaseAuthProvider() => _instance;

//   @override
//   AuthUser? get currentUser {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       return AuthUser.fromFirebase(user);
//     }
//     return null;
//   }

//   @override
//   bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

//   @override
//   Future<AuthUser> signInWithEmailAndPassword({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       final user = currentUser;
//       if (user != null) {
//         return user;
//       } else {
//         throw UserNotLoggedInAuthException();
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
//         throw UserNotFoundAuthException();
//       } else if (e.code == 'wrong-password') {
//         throw WrongPasswordAuthException();
//       } else if (e.code == 'invalid-email') {
//         throw InvalidEmailAuthException();
//       } else if (e.code == 'user-disabled') {
//         throw UserDisabledAuthException();
//       } else if (e.code == 'too-many-requests') {
//         throw TooManyRequestsAuthException();
//       } else {
//         throw GenericAuthException();
//       }
//     } catch (_) {
//       throw GenericAuthException();
//     }
//   }

//   @override
//   Future<AuthUser> signUpWithEmailAndPassword({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       final user = currentUser;
//       if (user != null) {
//         return user;
//       } else {
//         throw UserNotLoggedInAuthException();
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'weak-password') {
//         throw WeakPasswordAuthException();
//       } else if (e.code == 'email-already-in-use') {
//         throw EmailAlreadyInUseAuthException();
//       } else if (e.code == 'invalid-email') {
//         throw InvalidEmailAuthException();
//       } else {
//         throw GenericAuthException();
//       }
//     } catch (_) {
//       throw GenericAuthException();
//     }
//   }

//   @override
//   Future<void> signOut() async {
//     await FirebaseAuth.instance.signOut();
//   }

//   @override
//   Future<void> sendEmailVerification() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await user.sendEmailVerification();
//     } else {
//       throw UserNotLoggedInAuthException();
//     }
//   }

//   @override
//   Future<void> verifyEmail({
//     required String email,
//     required String code,
//   }) async {
//     // Firebase handles verification via links, but mapping the structure here
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         await user.reload();
//       }
//     } catch (_) {
//       throw GenericAuthException();
//     }
//   }

//   @override
//   Future<void> resetPassword({
//     required String email,
//     required String code,
//     required String newPassword,
//   }) async {
//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found') {
//         throw UserNotFoundAuthException();
//       } else if (e.code == 'invalid-email') {
//         throw InvalidEmailAuthException();
//       } else {
//         throw GenericAuthException();
//       }
//     } catch (_) {
//       throw GenericAuthException();
//     }
//   }

//   @override
//   void dispose() {}
// }
