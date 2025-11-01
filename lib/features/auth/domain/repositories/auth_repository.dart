import '../../../../core/usecase/usecase.dart';
import '../entities/auth.dart';

abstract class AuthRepository {
  ResultFuture<Auth> login(String username, String password);
  ResultFuture<Auth> register(RegisterPayload payload);
  ResultFuture<void> forgotPassword(String email);
  ResultFuture<void> logout();
}

class RegisterPayload {
  final String username;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String name;
  final String? phone;

  RegisterPayload({
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.name,
    this.phone,
  });
}
