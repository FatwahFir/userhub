import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_envelope.dart';
import '../../../../core/utils/error_parser.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/usecases/update_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(UpdateProfilePayload payload);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get<JsonMap>('/me');
      final envelope = ApiEnvelope<UserModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => UserModel.fromJson(json as JsonMap),
      );
      if (!envelope.success || envelope.data == null) {
        throw ServerException(
          message: envelope.error?.message ?? 'Failed to load profile',
          statusCode: response.statusCode ?? 400,
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
        'name': payload.name,
        'email': payload.email,
        if (payload.phone != null) 'phone': payload.phone,
        if (payload.avatarPath != null && payload.avatarPath!.isNotEmpty)
          'avatar': await MultipartFile.fromFile(payload.avatarPath!),
      });

      final response = await _dio.post<JsonMap>(
        '/me',
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      final envelope = ApiEnvelope<UserModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => UserModel.fromJson(json as JsonMap),
      );
      if (!envelope.success || envelope.data == null) {
        throw ServerException(
          message: envelope.error?.message ?? 'Failed to update profile',
          statusCode: response.statusCode ?? 400,
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
