part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;
  final String? errorMessage;
  final bool isSaving;
  final bool updateSuccess;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.errorMessage,
    this.isSaving = false,
    this.updateSuccess = false,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    String? errorMessage,
    bool clearError = false,
    bool? isSaving,
    bool? updateSuccess,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      updateSuccess: updateSuccess ?? this.updateSuccess,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        errorMessage,
        isSaving,
        updateSuccess,
      ];
}
