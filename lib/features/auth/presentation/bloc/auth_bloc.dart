import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/secure_storage.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/usecases/login_with_username_password.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/send_forgot_password.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithUsernamePassword loginUsecase;
  final RegisterUser registerUsecase;
  final LogoutUser logoutUsecase;
  final SendForgotPassword forgotUsecase;
  final SecureStorage storage;

  AuthBloc({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.logoutUsecase,
    required this.forgotUsecase,
    required this.storage,
  }) : super(const AuthState.unknown()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthErrorCleared>(_onErrorCleared);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    final token = await storage.readToken();
    final rawUser = await storage.readUser();
    if (token != null && rawUser != null) {
      final user = User(
        id: rawUser['id'] as int,
        username: rawUser['username'] as String,
        email: rawUser['email'] as String,
        name: rawUser['name'] as String,
        role: rawUser['role'] as String,
        avatarUrl: normalizeAvatarUrl(rawUser['avatar_url'] as String?),
        phone: rawUser['phone'] as String?,
        createdAt: rawUser['created_at'] != null
            ? DateTime.tryParse(rawUser['created_at'] as String)
            : null,
        updatedAt: rawUser['updated_at'] != null
            ? DateTime.tryParse(rawUser['updated_at'] as String)
            : null,
      );
      emit(AuthState.authenticated(token, user));
    } else {
      await storage.clear();
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, forgotPasswordEmailSent: false));
    final result = await loginUsecase(
      AuthCredentials(username: event.username, password: event.password),
    );

    await result.fold<Future<void>>(
      (failure) async {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            status: AuthStatus.unauthenticated,
          ),
        );
      },
      (auth) async {
        await storage.writeToken(auth.token);
        await storage.writeUser({
          'id': auth.user.id,
          'username': auth.user.username,
          'email': auth.user.email,
          'name': auth.user.name,
          'role': auth.user.role,
          'avatar_url': auth.user.avatarUrl,
          'phone': auth.user.phone,
          'created_at': auth.user.createdAt?.toIso8601String(),
          'updated_at': auth.user.updatedAt?.toIso8601String(),
        });
        emit(AuthState.authenticated(auth.token, auth.user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await registerUsecase(event.payload);

    await result.fold<Future<void>>(
      (failure) async {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            status: AuthStatus.unauthenticated,
          ),
        );
      },
      (auth) async {
        await storage.writeToken(auth.token);
        await storage.writeUser({
          'id': auth.user.id,
          'username': auth.user.username,
          'email': auth.user.email,
          'name': auth.user.name,
          'role': auth.user.role,
          'avatar_url': auth.user.avatarUrl,
          'phone': auth.user.phone,
          'created_at': auth.user.createdAt?.toIso8601String(),
          'updated_at': auth.user.updatedAt?.toIso8601String(),
        });
        emit(AuthState.authenticated(auth.token, auth.user));
      },
    );
  }

  Future<void> _onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, forgotPasswordEmailSent: false));
    final result = await forgotUsecase(event.email);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          status: AuthStatus.unauthenticated,
          forgotPasswordEmailSent: false,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: null,
          forgotPasswordEmailSent: true,
        ),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await logoutUsecase();

    await result.fold<Future<void>>(
      (failure) async {
        if (failure is ServerFailure && failure.statusCode == 401) {
          await storage.clear();
          emit(const AuthState.unauthenticated());
        } else {
          emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        }
      },
      (_) async {
        await storage.clear();
        emit(const AuthState.unauthenticated());
      },
    );
  }

  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(errorMessage: null, forgotPasswordEmailSent: false));
  }
}
