import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/utils/helper.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/user_list_bloc.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late final Debouncer _debouncer;
  bool _requestedInitial = false;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(delay: const Duration(milliseconds: 400));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      context.read<UserListBloc>().add(const UserListLoadMore());
    }
  }

  void _onSearchChanged(String value) {
    _debouncer(() {
      context.read<UserListBloc>().add(UserListQueryChanged(value));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedInitial) {
      context.read<UserListBloc>().add(const UserListRequested());
      _requestedInitial = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Users'),
        actions: [
          IconButton.filledTonal(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Iconsax.user),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: () => authBloc.add(const AuthLogoutRequested()),
            icon: const Icon(Iconsax.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0EBFF),
              Color(0xFFF5F7FB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Material(
                  elevation: 0,
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Iconsax.search_normal),
                      hintText: 'Search users...',
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
              ),
              Expanded(
                child: BlocConsumer<UserListBloc, UserListState>(
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(content: Text(state.errorMessage!)),
                        );
                    }
                  },
                  builder: (context, state) {
                    if (state.status == UserListStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == UserListStatus.failure &&
                        state.users.isEmpty) {
                      return _EmptyState(
                        message: state.errorMessage ?? 'Failed to load users',
                        actionLabel: 'Retry',
                        onAction: () => context
                            .read<UserListBloc>()
                            .add(const UserListRequested()),
                      );
                    }

                    if (state.users.isEmpty) {
                      return const _EmptyState(
                        icon: Iconsax.user_search,
                        message: 'No users found',
                        subtitle:
                            'Try adjusting your search or refreshing the list.',
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<UserListBloc>()
                            .add(const UserListRefreshed());
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                        itemCount:
                            state.users.length + (state.hasReachedMax ? 0 : 1),
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          if (index >= state.users.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final user = state.users[index];
                          return _UserCard(
                            user: user,
                            onTap: () => context.go('/users/${user.id}'),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    this.icon = Iconsax.user_remove,
    required this.message,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.onTap,
  });

  String _formatRole(String role) {
    if (role.isEmpty) return role;
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage:
                    user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                child: user.avatarUrl == null
                    ? const Icon(Iconsax.user, size: 26)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Chip(
                label: Text(_formatRole(user.role)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
