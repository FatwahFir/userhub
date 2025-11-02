import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_envelope.dart';
import '../../../../core/utils/error_parser.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/usecases/update_profile.dart';

part 'profile_remote_datasource.g.dart';

@RestApi()
abstract class ProfileApi {
  factory ProfileApi(Dio dio, {String baseUrl}) = _ProfileApi;

  @GET('/me')
  Future<ApiEnvelope<UserModel>> getProfile();

  @POST('/me')
  Future<ApiEnvelope<UserModel>> updateProfile(@Body() FormData body);
}

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(UpdateProfilePayload payload);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ProfileApi _api;

  ProfileRemoteDataSourceImpl(this._api);

  @override
  Future<UserModel> getProfile() async {
    try {
      final envelope = await _api.getProfile();
      if (!envelope.success || envelope.data == null) {
        throw ServerException(
          message: envelope.error?.message ?? 'Failed to load profile',
          statusCode: 400,
        );
      }
      return envelope.data!;
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  @override
  Future<UserModel> updateProfile(UpdateProfilePayload payload) async {
    try {
      final data = FormData.fromMap({
        '_method': 'PUT',
        'username': payload.username,
        'name': payload.name,
        'email': payload.email,
        if (payload.phone != null) 'phone': payload.phone,
        if (payload.avatarPath != null && payload.avatarPath!.isNotEmpty)
          'avatar': await MultipartFile.fromFile(payload.avatarPath!),
      });

      final envelope = await _api.updateProfile(data);
      if (!envelope.success || envelope.data == null) {
        throw ServerException(
          message: envelope.error?.message ?? 'Failed to update profile',
          statusCode: 400,
        );
      }
      return envelope.data!;
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  ServerException _mapDioError(DioException error) {
    final status = error.response?.statusCode ?? 500;
    final message = parseApiErrorMessage(
      error.response?.data,
      fallback: error.message ?? 'Server error',
    );
    return ServerException(message: message, statusCode: status);
  }
}
