import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../app/di/injector.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import 'secure_storage.dart';

class DioClient {
  final Dio dio;

  DioClient._(this.dio);

  static DioClient create(String baseUrl, SecureStorage storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.extra['startTime'] = DateTime.now();
          if (kDebugMode) {
            debugPrint('→ ${options.method} ${options.uri}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            final start = response.requestOptions.extra['startTime'] as DateTime?;
            final elapsed = start == null
                ? ''
                : ' (${DateTime.now().difference(start).inMilliseconds}ms)';
            debugPrint('← ${response.statusCode} ${response.realUri}$elapsed');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            final start = error.requestOptions.extra['startTime'] as DateTime?;
            final elapsed = start == null
                ? ''
                : ' (${DateTime.now().difference(start).inMilliseconds}ms)';
            debugPrint(
              '✕ ${error.response?.statusCode ?? '-'} '
              '${error.requestOptions.method} ${error.requestOptions.uri}$elapsed '
              '- ${error.message}',
            );
          }
          handler.next(error);
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            final authHeader =
                error.requestOptions.headers['Authorization']?.toString();
            final shouldLogout =
                authHeader != null && authHeader.trim().isNotEmpty;

            if (shouldLogout) {
              dio.options.headers.remove('Authorization');
              sl<AuthBloc>().add(const AuthLogoutRequested());
            }
          }
          handler.next(error);
        },
      ),
    );

    return DioClient._(dio);
  }
}
