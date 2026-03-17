// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'auth_cubit.dart';

enum AuthStatus { initial, loading, unauthenticated, authenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String errorMessage;
  final User? user;
  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage = '',
    this.user,
  });

  @override
  List<Object?> get props => [status, errorMessage, user];

  AuthState copyWith({AuthStatus? status, String? errorMessage, User? user}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}
