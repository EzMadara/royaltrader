import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:royaltrader/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthCubit() : super(AuthInitial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      emit(AuthAuthenticated(currentUser));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      emit(AuthLoading());
      final UserCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (UserCredential.user != null) {
        emit(AuthAuthenticated(UserCredential.user!));
      } else {
        emit(AuthUnauthenticated());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Auth Failed'));
    } catch (e) {
      emit(AuthError('Unexpected Error'));
    }
  }

  Future<void> registerWithEmailPassword(String email, String password) async {
    try {
      emit(AuthLoading());
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        emit(AuthAuthenticated(userCredential.user!));
      } else {
        emit(AuthUnauthenticated());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Registration failed'));
    } catch (e) {
      emit(AuthError('An unexpected error occurred'));
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Sign out failed'));
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      emit(AuthLoading());
      await _auth.sendPasswordResetEmail(email: email);
      emit(AuthUnauthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Password reset failed'));
    } catch (e) {
      emit(AuthError('An unexpected error occurred'));
    }
  }
}
