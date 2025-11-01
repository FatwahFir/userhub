import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_envelope.dart';
import '../../../../core/utils/error_parser.dart';
import '../../../../core/utils/paged_result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../auth/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<PagedResult<UserModel>> getUsers({
    required int page,
    required int size,
    String? query,
  });

  Future<UserModel> getUserDetail(int id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSourceImpl(this._dio);

  @override
  Future<PagedResult<UserModel>> getUsers({
    required int page,
    required int size,
    String? query,
  }) async {
    try {
      final response = await _dio.get<JsonMap>(
        '/users',
        queryParameters: {
          'page': page,
          'size': size,
          if (query != null && query.isNotEmpty) 'q': query,
        },
      );

      final envelope = ApiEnvelope<List<UserModel>>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => (json as List<dynamic>)
            .map((item) => UserModel.fromJson(item as JsonMap))
            .toList(),
      );

      if (!envelope.success || envelope.data == null) {
        throw ServerException(
          message: envelope.error?.message ?? 'Failed to load users',
          statusCode: response.statusCode ?? 400,
        );
      }

      final pagination = envelope.pagination;
      return PagedResult<UserModel>(
        items: envelope.data!,
        page: pagination?.page ?? page,
        pageSize: pagination?.pageSize ?? envelope.data!.length,
        total: pagination?.total ?? envelope.data!.length,
        totalPages: pagination?.totalPages ?? page,
      );
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  @override
  Future<UserModel> getUserDetail(int id) async {
    try {
      final response = await _dio.get<JsonMap>('/users/$id');
      final envelope = ApiEnvelope<UserModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => UserModel.fromJson(json as JsonMap),
      );

      if (!envelope.success || envelope.data == null) {
        throw ServerException(
          message: envelope.error?.message ?? 'Failed to load user detail',
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
