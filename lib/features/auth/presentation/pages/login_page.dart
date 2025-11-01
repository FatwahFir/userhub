import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.status != current.status,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<AuthBloc>().add(const AuthErrorCleared());
          }
          if (state.authenticated) {
            context.go('/users');
          }
        },
        builder: (context, state) {
          final isLoading = state.isLoading;
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF3B82F6),
                      Color(0xFFF5F7FB),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in with your credentials to continue.',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withOpacity(.9),
                                ),
                          ),
                          const SizedBox(height: 32),
                          Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
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
                                            Iconsax.profile_circle,
                                            color:
                                                Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Account details',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    TextFormField(
                                      controller: _usernameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Username or Email',
                                        prefixIcon: Icon(Iconsax.user),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(Iconsax.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Iconsax.eye_slash
                                                : Iconsax.eye,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => context.push('/forgot-password'),
                                        child: const Text('Forgot password?'),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        onPressed: isLoading ? null : _submit,
                                        icon: const Icon(Iconsax.login),
                                        label: const Text('Login'),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'New here?',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: Colors.grey[600]),
                                        ),
                                        TextButton(
                                          onPressed: () => context.push('/register'),
                                          child: const Text('Create an account'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x88000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
