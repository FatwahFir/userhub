import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/user_repository.dart';

class GetUserDetail extends UsecaseWithParams<User, int> {
  final UserRepository repository;

  const GetUserDetail(this.repository);

  @override
  ResultFuture<User> call(int params) => repository.getUserDetail(params);
}
