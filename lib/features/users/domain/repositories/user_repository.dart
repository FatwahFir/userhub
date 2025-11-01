import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/paged_result.dart';
import '../../../auth/domain/entities/user.dart';

abstract class UserRepository {
  ResultFuture<PagedResult<User>> getUsers(GetUsersParams params);
  ResultFuture<User> getUserDetail(int id);
}

class GetUsersParams {
  final int page;
  final int size;
  final String? query;

  const GetUsersParams({
    required this.page,
    required this.size,
    this.query,
  });
}
