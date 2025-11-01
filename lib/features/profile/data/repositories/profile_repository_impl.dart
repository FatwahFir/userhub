import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/secure_storage.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../datasources/profile_remote_datasource.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  final SecureStorage storage;

  ProfileRepositoryImpl(this.remote, this.storage);

  @override
  ResultFuture<User> getProfile() async {
    try {
      final model = await remote.getProfile();
      final user = model.toEntity();
      await storage.writeUser({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'name': user.name,
        'role': user.role,
        'avatar_url': user.avatarUrl,
        'phone': user.phone,
        'created_at': user.createdAt?.toIso8601String(),
        'updated_at': user.updatedAt?.toIso8601String(),
      });
      return Right(user);
    } on ServerException catch (error) {
      return Left(
        ServerFailure(message: error.message, statusCode: error.statusCode),
      );
    }
  }

  @override
  ResultFuture<User> updateProfile(UpdateProfilePayload payload) async {
    try {
      final model = await remote.updateProfile(payload);
      final user = model.toEntity();
      await storage.writeUser({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'name': user.name,
        'role': user.role,
        'avatar_url': user.avatarUrl,
        'phone': user.phone,
        'created_at': user.createdAt?.toIso8601String(),
        'updated_at': user.updatedAt?.toIso8601String(),
      });
      return Right(user);
    } on ServerException catch (error) {
      return Left(
        ServerFailure(message: error.message, statusCode: error.statusCode),
      );
    }
  }
}
