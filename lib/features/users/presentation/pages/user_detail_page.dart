import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../auth/domain/entities/user.dart';
import '../bloc/user_detail_bloc.dart';

class UserDetailPage extends StatefulWidget {
  final int userId;

  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      context.read<UserDetailBloc>().add(UserDetailRequested(widget.userId));
      _requested = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Detail')),
      body: BlocBuilder<UserDetailBloc, UserDetailState>(
        builder: (context, state) {
          if (state.status == UserDetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == UserDetailStatus.failure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Failed to load user'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<UserDetailBloc>()
                        .add(UserDetailRequested(widget.userId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = state.user;
          if (user == null) {
            return const SizedBox.shrink();
          }

          return _UserDetailContent(user: user);
        },
      ),
    );
  }
}

class _UserDetailContent extends StatelessWidget {
  final User user;

  const _UserDetailContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage:
                  user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                  ? const Icon(Iconsax.user, size: 40)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 24),
          _DetailRow(
            icon: Iconsax.user,
            label: 'Username',
            value: user.username,
          ),
          _DetailRow(
            icon: Iconsax.personalcard,
            label: 'Role',
            value: user.role,
          ),
          _DetailRow(
            icon: Iconsax.call,
            label: 'Phone',
            value: user.phone ?? '-',
          ),
          if (user.createdAt != null)
            _DetailRow(
              icon: Iconsax.calendar,
              label: 'Joined',
              value: MaterialLocalizations.of(context)
                  .formatFullDate(user.createdAt!),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
