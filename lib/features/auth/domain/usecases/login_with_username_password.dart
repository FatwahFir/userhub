import 'package:equatable/equatable.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class LoginWithUsernamePassword
    extends UsecaseWithParams<Auth, AuthCredentials> {
  final AuthRepository repository;

  const LoginWithUsernamePassword(this.repository);

  @override
  ResultFuture<Auth> call(AuthCredentials params) =>
      repository.login(params.username, params.password);
}

class AuthCredentials extends Equatable {
  final String username;
  final String password;

  const AuthCredentials({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}
