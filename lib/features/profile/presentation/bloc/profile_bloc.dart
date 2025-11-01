import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final AuthBloc authBloc;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.authBloc,
  }) : super(
          authBloc.state.user == null
              ? const ProfileState()
              : ProfileState(
                  status: ProfileStatus.loaded,
                  user: authBloc.state.user,
                ),
        ) {
    on<ProfileRequested>(_onProfileRequested);
    on<ProfileUpdated>(_onProfileUpdated);
    on<ProfileErrorCleared>(_onProfileErrorCleared);
  }

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        clearError: true,
        updateSuccess: false,
      ),
    );
    final result = await getProfile();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          user: user,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onProfileUpdated(
    ProfileUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        isSaving: true,
        clearError: true,
        updateSuccess: false,
      ),
    );
    final result = await updateProfile(event.payload);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isSaving: false,
          errorMessage: failure.message,
          updateSuccess: false,
        ),
      ),
      (user) {
        authBloc.add(const AuthCheckStatus());
        emit(
          state.copyWith(
            isSaving: false,
            user: user,
            status: ProfileStatus.loaded,
            clearError: true,
            updateSuccess: true,
          ),
        );
      },
    );
  }

  void _onProfileErrorCleared(
    ProfileErrorCleared event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        clearError: true,
        updateSuccess: false,
      ),
    );
  }
}
