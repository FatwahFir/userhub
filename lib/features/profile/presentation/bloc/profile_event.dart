part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

class ProfileUpdated extends ProfileEvent {
  final UpdateProfilePayload payload;

  const ProfileUpdated(this.payload);

  @override
  List<Object?> get props => [payload];
}

class ProfileErrorCleared extends ProfileEvent {
  const ProfileErrorCleared();
}
