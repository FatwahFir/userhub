part of 'user_detail_bloc.dart';

enum UserDetailStatus { initial, loading, success, failure }

class UserDetailState extends Equatable {
  final UserDetailStatus status;
  final User? user;
  final String? errorMessage;

  const UserDetailState({
    this.status = UserDetailStatus.initial,
    this.user,
    this.errorMessage,
  });

  UserDetailState copyWith({
    UserDetailStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return UserDetailState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
