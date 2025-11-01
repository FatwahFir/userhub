part of 'user_list_bloc.dart';

abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object?> get props => [];
}

class UserListRequested extends UserListEvent {
  const UserListRequested();
}

class UserListLoadMore extends UserListEvent {
  const UserListLoadMore();
}

class UserListQueryChanged extends UserListEvent {
  final String query;

  const UserListQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class UserListRefreshed extends UserListEvent {
  const UserListRefreshed();
}
