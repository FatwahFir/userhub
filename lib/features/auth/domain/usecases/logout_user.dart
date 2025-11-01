import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUser extends UsecaseWithoutParams<void> {
  final AuthRepository repository;

  const LogoutUser(this.repository);

  @override
  ResultFuture<void> call() => repository.logout();
}
