import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/paged_result.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;

  UserRepositoryImpl(this.remote);

  @override
  ResultFuture<PagedResult<User>> getUsers(GetUsersParams params) async {
    try {
      final result = await remote.getUsers(
        page: params.page,
        size: params.size,
        query: params.query,
      );

      return Right(
        PagedResult<User>(
          items: result.items.map((model) => model.toEntity()).toList(),
          page: result.page,
          pageSize: result.pageSize,
          total: result.total,
          totalPages: result.totalPages,
        ),
      );
    } on ServerException catch (error) {
      return Left(
        ServerFailure(message: error.message, statusCode: error.statusCode),
      );
    }
  }

  @override
  ResultFuture<User> getUserDetail(int id) async {
    try {
      final model = await remote.getUserDetail(id);
      return Right(model.toEntity());
    } on ServerException catch (error) {
      return Left(
        ServerFailure(message: error.message, statusCode: error.statusCode),
      );
    }
  }
}
