import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile extends UsecaseWithParams<User, UpdateProfilePayload> {
  final ProfileRepository repository;

  const UpdateProfile(this.repository);

  @override
  ResultFuture<User> call(UpdateProfilePayload params) =>
      repository.updateProfile(params);
}

class UpdateProfilePayload {
  final String name;
  final String email;
  final String? phone;
  final String? avatarPath;

  UpdateProfilePayload({
    required this.name,
    required this.email,
    this.phone,
    this.avatarPath,
  });
}
