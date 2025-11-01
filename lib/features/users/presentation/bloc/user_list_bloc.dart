import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_users.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final GetUsers getUsers;
  static const int _pageSize = 20;

  UserListBloc({required this.getUsers}) : super(const UserListState()) {
    on<UserListRequested>(_onRequested);
    on<UserListLoadMore>(_onLoadMore);
    on<UserListQueryChanged>(_onQueryChanged);
    on<UserListRefreshed>(_onRefreshed);
  }

  Future<void> _onRequested(
    UserListRequested event,
    Emitter<UserListState> emit,
  ) async {
    emit(
      state.copyWith(
        status: UserListStatus.loading,
        page: 1,
        hasReachedMax: false,
        errorMessage: null,
      ),
    );

    final result = await getUsers(
      GetUsersParams(
        page: 1,
        size: _pageSize,
        query: state.query.isEmpty ? null : state.query,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UserListStatus.failure,
          errorMessage: failure.message,
          users: [],
        ),
      ),
      (paged) => emit(
        state.copyWith(
          status: UserListStatus.success,
          users: paged.items,
          page: paged.page,
          hasReachedMax: !paged.hasMore,
          total: paged.total,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    UserListLoadMore event,
    Emitter<UserListState> emit,
  ) async {
    if (state.status != UserListStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, errorMessage: null));

    final nextPage = state.page + 1;
    final result = await getUsers(
      GetUsersParams(
        page: nextPage,
        size: _pageSize,
        query: state.query.isEmpty ? null : state.query,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
        ),
      ),
      (paged) => emit(
        state.copyWith(
          users: [...state.users, ...paged.items],
          page: paged.page,
          hasReachedMax: !paged.hasMore,
          isLoadingMore: false,
          total: paged.total,
        ),
      ),
    );
  }

  Future<void> _onQueryChanged(
    UserListQueryChanged event,
    Emitter<UserListState> emit,
  ) async {
    final query = event.query.trim();
    emit(
      state.copyWith(
        query: query,
        page: 1,
        hasReachedMax: false,
      ),
    );
    add(const UserListRequested());
  }

  Future<void> _onRefreshed(
    UserListRefreshed event,
    Emitter<UserListState> emit,
  ) async {
    add(const UserListRequested());
  }
}
