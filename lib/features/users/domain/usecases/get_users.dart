import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/paged_result.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/user_repository.dart';

class GetUsers extends UsecaseWithParams<PagedResult<User>, GetUsersParams> {
  final UserRepository repository;

  const GetUsers(this.repository);

  @override
  ResultFuture<PagedResult<User>> call(GetUsersParams params) =>
      repository.getUsers(params);
}
