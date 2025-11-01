import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton.filledTonal(
            onPressed: () => context.push('/profile/edit'),
            icon: const Icon(Iconsax.edit),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            icon: const Icon(Iconsax.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0EBFF),
              Color(0xFFF5F7FB),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              }
            },
            builder: (context, state) {
              if (state.status == ProfileStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              final user = state.user ?? context.read<AuthBloc>().state.user;
              if (user == null) {
                return Center(
                  child: FilledButton(
                    onPressed: () => context
                        .read<ProfileBloc>()
                        .add(const ProfileRequested()),
                    child: const Text('Reload'),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileBloc>().add(const ProfileRequested());
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2563EB),
                            Color(0xFF3B82F6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 18,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            backgroundColor: Colors.white.withOpacity(.15),
                            child: user.avatarUrl == null
                                ? const Icon(Iconsax.user, size: 40, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            user.name,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user.email,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withOpacity(.85),
                                ),
                          ),
                          const SizedBox(height: 18),
                          Chip(
                            label: Text(
                              _formatRole(user.role),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: Colors.white.withOpacity(.16),
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Iconsax.personalcard,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Account information',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _ProfileInfoRow(
                              icon: Iconsax.user,
                              label: 'Username',
                              value: user.username,
                            ),
                            _ProfileInfoRow(
                              icon: Iconsax.call,
                              label: 'Phone',
                              value: user.phone ?? '-',
                            ),
                            if (user.createdAt != null)
                              _ProfileInfoRow(
                                icon: Iconsax.calendar,
                                label: 'Joined',
                                value: MaterialLocalizations.of(context)
                                    .formatShortDate(user.createdAt!),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatRole(String role) {
  if (role.isEmpty) return role;
  return role[0].toUpperCase() + role.substring(1).toLowerCase();
}
