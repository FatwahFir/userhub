part of 'user_list_bloc.dart';

enum UserListStatus { initial, loading, success, failure }

class UserListState extends Equatable {
  final UserListStatus status;
  final List<User> users;
  final int page;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String query;
  final String? errorMessage;
  final int total;

  const UserListState({
    this.status = UserListStatus.initial,
    this.users = const [],
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.query = '',
    this.errorMessage,
    this.total = 0,
  });

  UserListState copyWith({
    UserListStatus? status,
    List<User>? users,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? query,
    String? errorMessage,
    int? total,
  }) {
    return UserListState(
      status: status ?? this.status,
      users: users ?? this.users,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      query: query ?? this.query,
      errorMessage: errorMessage,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [
        status,
        users,
        page,
        hasReachedMax,
        isLoadingMore,
        query,
        errorMessage,
        total,
      ];
}
