import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SendForgotPassword extends UsecaseWithParams<void, String> {
  final AuthRepository repository;

  const SendForgotPassword(this.repository);

  @override
  ResultFuture<void> call(String params) => repository.forgotPassword(params);
}
