import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  ResultFuture<Auth> login(String username, String password) async {
    try {
      final model = await datasource.login(username, password);
      return Right(model.toEntity());
    } on ServerException catch (error) {
      return Left(
        ServerFailure(message: error.message, statusCode: error.statusCode),
      );
    }
  }

  @override
  ResultFuture<Auth> register(RegisterPayload payload) async {
    try {
      final model = await datasource.register(
        payload.username,
        payload.email,
        payload.password,
        payload.passwordConfirmation,
        payload.name,
        phone: payload.phone,
      );
      return Right(model.toEntity());
    } on ServerException catch (error) {
      return Left(
        ServerFailure(message: error.message, statusCode: error.statusCode),
      );
    }
  }

  @override
  ResultFuture<void> forgotPassword(String email) async {
    try {
      await datasource.forgotPassword(email);
      return const Right(null);
    } on ServerException catch (error) {
      return Left(
        ServerFailure(message: error.message, statusCode: error.statusCode),
      );
    }
  }

  @override
  ResultFuture<void> logout() async {
    try {
      await datasource.logout();
      return const Right(null);
    } on ServerException catch (error) {
      return Left(
        ServerFailure(message: error.message, statusCode: error.statusCode),
      );
    }
  }
}
