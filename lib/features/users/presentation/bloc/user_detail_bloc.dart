import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../domain/usecases/get_user_detail.dart';

part 'user_detail_event.dart';
part 'user_detail_state.dart';

class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  final GetUserDetail getUserDetail;

  UserDetailBloc({required this.getUserDetail})
      : super(const UserDetailState()) {
    on<UserDetailRequested>(_onRequested);
  }

  Future<void> _onRequested(
    UserDetailRequested event,
    Emitter<UserDetailState> emit,
  ) async {
    emit(state.copyWith(status: UserDetailStatus.loading, errorMessage: null));
    final result = await getUserDetail(event.id);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UserDetailStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: UserDetailStatus.success,
          user: user,
        ),
      ),
    );
  }
}
