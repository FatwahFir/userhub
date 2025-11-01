import '../../../../core/usecase/usecase.dart';
import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class RegisterUser extends UsecaseWithParams<Auth, RegisterPayload> {
  final AuthRepository repository;

  const RegisterUser(this.repository);

  @override
  ResultFuture<Auth> call(RegisterPayload params) =>
      repository.register(params);
}
