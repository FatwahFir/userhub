part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

class AuthRegisterRequested extends AuthEvent {
  final RegisterPayload payload;

  const AuthRegisterRequested(this.payload);

  @override
  List<Object?> get props => [payload];
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
