import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_list/data/remote_datasources/auth/auth_remote_datasource.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final _auth = AuthRemoteDatasource();

  StreamSubscription<User?>? _userSubscription;

  AuthCubit() : super(const AuthState()) {
    _userSubscription = _auth.user.listen((user) {
      if (user != null) {
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
      }
    });
  }

  Future<bool> signIn(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _auth.signIn(email, password);

      return true;
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );

      return false;
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );

      return false;
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String confirmationPassword,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _auth.signUp(email, password);

      return true;
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );

      return false;
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );

      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
