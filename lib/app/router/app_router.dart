import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/users/presentation/bloc/user_detail_bloc.dart';
import '../../features/users/presentation/bloc/user_list_bloc.dart';
import '../../features/users/presentation/pages/user_detail_page.dart';
import '../../features/users/presentation/pages/user_list_page.dart';
import '../di/injector.dart';

class AppRouter {
  static GoRouter build(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: BlocStreamListenable(authBloc.stream),
      redirect: (context, state) {
        final authed = authBloc.state.authenticated;
        final loggingIn = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/forgot-password';
        if (!authed && !loggingIn) return '/login';
        if (authed && loggingIn) return '/users';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (_, __) => const RegisterPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<UserListBloc>()),
            ],
            child: const UserListPage(),
          ),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => sl<UserDetailBloc>()),
                  ],
                  child: UserDetailPage(userId: id),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) {
            final bloc = sl<ProfileBloc>();
            if (bloc.state.status == ProfileStatus.initial) {
              bloc.add(const ProfileRequested());
            }
            return BlocProvider<ProfileBloc>.value(
              value: bloc,
              child: const ProfilePage(),
            );
          },
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) {
                final bloc = sl<ProfileBloc>();
                if (bloc.state.status == ProfileStatus.initial) {
                  bloc.add(const ProfileRequested());
                }
                return BlocProvider<ProfileBloc>.value(
                  value: bloc,
                  child: const EditProfilePage(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class BlocStreamListenable extends ChangeNotifier {
  BlocStreamListenable(Stream stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
