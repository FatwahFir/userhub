import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../usecases/update_profile.dart';

abstract class ProfileRepository {
  ResultFuture<User> getProfile();
  ResultFuture<User> updateProfile(UpdateProfilePayload payload);
}
