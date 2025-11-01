import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

class GetProfile extends UsecaseWithoutParams<User> {
  final ProfileRepository repository;

  const GetProfile(this.repository);

  @override
  ResultFuture<User> call() => repository.getProfile();
}
