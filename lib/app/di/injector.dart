import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/services/dio_client.dart';
import '../../core/services/secure_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_with_username_password.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/send_forgot_password.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/users/data/datasources/user_remote_datasource.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/domain/usecases/get_user_detail.dart';
import '../../features/users/domain/usecases/get_users.dart';
import '../../features/users/presentation/bloc/user_detail_bloc.dart';
import '../../features/users/presentation/bloc/user_list_bloc.dart';

final sl = GetIt.instance;

Future<void> initDI(String baseUrl) async {
  sl
    ..registerLazySingleton<SecureStorage>(() => SecureStorageImpl())
    ..registerLazySingleton<Dio>(
      () => DioClient.create(baseUrl, sl<SecureStorage>()).dio,
    )
    ..registerLazySingleton<AuthApi>(() => AuthApi(sl<Dio>()))
    ..registerLazySingleton<ProfileApi>(() => ProfileApi(sl<Dio>()))
    ..registerLazySingleton<UserApi>(() => UserApi(sl<Dio>()))

    // Auth
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
          sl<AuthApi>(), sl<Dio>(), sl<SecureStorage>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
    )
    ..registerLazySingleton(() => LoginWithUsernamePassword(sl()))
    ..registerLazySingleton(() => RegisterUser(sl()))
    ..registerLazySingleton(() => SendForgotPassword(sl()))
    ..registerLazySingleton(() => LogoutUser(sl()))
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        loginUsecase: sl(),
        registerUsecase: sl(),
        logoutUsecase: sl(),
        forgotUsecase: sl(),
        storage: sl(),
      ),
    )

    // Profile
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(sl<ProfileApi>()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
          sl<ProfileRemoteDataSource>(), sl<SecureStorage>()),
    )
    ..registerLazySingleton(() => GetProfile(sl()))
    ..registerLazySingleton(() => UpdateProfile(sl()))
    ..registerLazySingleton<ProfileBloc>(
      () => ProfileBloc(
        getProfile: sl(),
        updateProfile: sl(),
        authBloc: sl<AuthBloc>(),
      ),
    )

    // Users
    ..registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(sl<UserApi>()),
    )
    ..registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(sl<UserRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetUsers(sl()))
    ..registerLazySingleton(() => GetUserDetail(sl()))
    ..registerFactory(
      () => UserListBloc(
        getUsers: sl(),
      ),
    )
    ..registerFactory(
      () => UserDetailBloc(
        getUserDetail: sl(),
      ),
    );
}
