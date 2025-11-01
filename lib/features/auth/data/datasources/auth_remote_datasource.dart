import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/secure_storage.dart';
import '../../../../core/utils/api_envelope.dart';
import '../../../../core/utils/error_parser.dart';
import '../../../../core/utils/typedefs.dart';
import '../models/auth_model.dart';
import '../models/message_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String username, String password);
  Future<AuthModel> register(
    String username,
    String email,
    String password,
    String passwordConfirmation,
    String name, {
    String? phone,
  });
  Future<void> forgotPassword(String email);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final SecureStorage _storage;

  AuthRemoteDataSourceImpl(this._dio, this._storage);

  @override
  Future<AuthModel> login(String username, String password) async {
    try {
      final response = await _dio.post<JsonMap>(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final envelope = ApiEnvelope<AuthModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => AuthModel.fromJson(json as JsonMap),
      );

      if (!envelope.success || envelope.data == null) {
        throw ServerException(
          message: envelope.error?.message ?? 'Login failed',
          statusCode: response.statusCode ?? 400,
        );
      }

      _dio.options.headers['Authorization'] = 'Bearer ${envelope.data!.token}';
      return envelope.data!;
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  @override
  Future<AuthModel> register(
    String username,
    String email,
    String password,
    String passwordConfirmation,
    String name, {
    String? phone,
  }) async {
    try {
      final formData = FormData.fromMap({
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'name': name,
        if (phone != null) 'phone': phone,
      });

      final response = await _dio.post<JsonMap>(
        '/auth/register',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final envelope = ApiEnvelope<AuthModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => AuthModel.fromJson(json as JsonMap),
      );

      if (!envelope.success || envelope.data == null) {
        throw ServerException(
          message: envelope.error?.message ?? 'Register failed',
          statusCode: response.statusCode ?? 400,
        );
      }

      _dio.options.headers['Authorization'] = 'Bearer ${envelope.data!.token}';
      return envelope.data!;
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _dio.post<JsonMap>(
        '/auth/forgot-password',
        data: {'email': email},
      );

      final envelope = ApiEnvelope<MessageModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => MessageModel.fromJson(json as JsonMap),
      );

      if (!envelope.success) {
        throw ServerException(
          message: envelope.error?.message ?? 'Request failed',
          statusCode: response.statusCode ?? 400,
        );
      }
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post<JsonMap>('/auth/logout');
      _dio.options.headers.remove('Authorization');
      await _storage.clear();
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
