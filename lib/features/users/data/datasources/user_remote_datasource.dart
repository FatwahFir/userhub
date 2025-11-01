import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_envelope.dart';
import '../../../../core/utils/error_parser.dart';
import '../../../../core/utils/paged_result.dart';
import '../../../auth/data/models/user_model.dart';

part 'user_remote_datasource.g.dart';

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String baseUrl}) = _UserApi;

  @GET('/users')
  Future<ApiEnvelope<List<UserModel>>> getUsers(
    @Query('page') int page,
    @Query('size') int size,
    @Query('q') String? query,
  );

  @GET('/users/{id}')
  Future<ApiEnvelope<UserModel>> getUserDetail(@Path('id') int id);
}

abstract class UserRemoteDataSource {
  Future<PagedResult<UserModel>> getUsers({
    required int page,
    required int size,
    String? query,
  });

  Future<UserModel> getUserDetail(int id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final UserApi _api;

  UserRemoteDataSourceImpl(this._api);

  @override
  Future<PagedResult<UserModel>> getUsers({
    required int page,
    required int size,
    String? query,
  }) async {
    try {
      final envelope = await _api.getUsers(page, size, query);
      if (!envelope.success || envelope.data == null) {
        throw ServerException(
          message: envelope.error?.message ?? 'Failed to load users',
          statusCode: 400,
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
      final envelope = await _api.getUserDetail(id);
      if (!envelope.success || envelope.data == null) {
        throw ServerException(
          message: envelope.error?.message ?? 'Failed to load user detail',
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
