import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/secure_storage.dart';
import '../../../../core/utils/api_envelope.dart';
import '../../../../core/utils/error_parser.dart';
import '../models/auth_model.dart';
import '../models/message_model.dart';

part 'auth_remote_datasource.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  @POST('/auth/login')
  Future<ApiEnvelope<AuthModel>> login(@Body() Map<String, dynamic> body);

  @POST('/auth/register')
  Future<ApiEnvelope<AuthModel>> register(@Body() FormData body);

  @POST('/auth/forgot-password')
  Future<ApiEnvelope<MessageModel>> forgotPassword(
    @Body() Map<String, dynamic> body,
  );

  @POST('/auth/logout')
  Future<ApiEnvelope<MessageModel>> logout();
}

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
  final AuthApi _api;
  final Dio _dio;
  final SecureStorage _storage;

  AuthRemoteDataSourceImpl(this._api, this._dio, this._storage);

  @override
  Future<AuthModel> login(String username, String password) async {
    try {
      final envelope = await _api.login({
        'username': username,
        'password': password,
      });
      if (!envelope.success || envelope.data == null) {
        throw ServerException(
          message: envelope.error?.message ?? 'Login failed',
          statusCode: 400,
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

      final envelope = await _api.register(formData);
      if (!envelope.success || envelope.data == null) {
        throw ServerException(
          message: envelope.error?.message ?? 'Register failed',
          statusCode: 400,
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
      final envelope = await _api.forgotPassword({'email': email});

      if (!envelope.success) {
        throw ServerException(
          message: envelope.error?.message ?? 'Request failed',
          statusCode: 400,
        );
      }
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _api.logout();
    } on DioException catch (error) {
      throw _mapDioError(error);
    } finally {
      _dio.options.headers.remove('Authorization');
      await _storage.clear();
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
