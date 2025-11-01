part of 'auth_bloc.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? token;
  final bool isLoading;
  final String? errorMessage;
  final bool forgotPasswordEmailSent;

  const AuthState({
    required this.status,
    required this.user,
    required this.token,
    required this.isLoading,
    required this.errorMessage,
    required this.forgotPasswordEmailSent,
  });

  const AuthState.unknown()
      : this(
          status: AuthStatus.unknown,
          user: null,
          token: null,
          isLoading: false,
          errorMessage: null,
          forgotPasswordEmailSent: false,
        );

  const AuthState.unauthenticated()
      : this(
          status: AuthStatus.unauthenticated,
          user: null,
          token: null,
          isLoading: false,
          errorMessage: null,
          forgotPasswordEmailSent: false,
        );

  factory AuthState.authenticated(String token, User user) => AuthState(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
        isLoading: false,
        errorMessage: null,
        forgotPasswordEmailSent: false,
      );

  bool get authenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    bool? isLoading,
    String? errorMessage,
    bool? forgotPasswordEmailSent,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      forgotPasswordEmailSent:
          forgotPasswordEmailSent ?? this.forgotPasswordEmailSent,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        token,
        isLoading,
        errorMessage,
        forgotPasswordEmailSent,
      ];
}
