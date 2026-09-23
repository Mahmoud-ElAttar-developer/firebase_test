import 'package:bloc/bloc.dart';
import 'package:firebase_test/sevices/auth/auth_provider.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_event.dart';
import 'package:firebase_test/sevices/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
    : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    });
    //forgot password
    on<AuthEventForgotPassword>((event, emit) async {
      emit(
        const AuthStateForgotPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: false,
        ),
      );
      final email = event.email;
      if (email == null) {
        return; // user just wants to go to forgot-password screen
      }

      // user wants to actually send a forgot-password email
      emit(
        const AuthStateForgotPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: true,
        ),
      );

      bool didSendEmail;
      Exception? exception;
      try {
        await provider.resetPassword(
          email: event.email ?? '',
          code: event.code ?? '', // 👈 كدة هيقرأ الكود من الـ event علطول
          newPassword: event.newPassword ?? '', // 👈 وكدة هيقرأ الباسورد الجديد
        );
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }

      emit(
        AuthStateForgotPassword(
          exception: exception,
          hasSentEmail: didSendEmail,
          isLoading: false,
        ),
      );
    });
    // send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });
    // initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });
    // log in
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while I log you in',
        ),
      );
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
    // log out
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.signOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
    on<AuthEventChangeLanguage>((event, emit) {
      // هنا يتم حفظ اللغة الجديدة وإصدار حالة (State) لتحديث الـ MaterialApp
      emit(state); 
    });
  }
}
