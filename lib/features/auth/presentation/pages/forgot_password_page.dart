import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../bloc/auth_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
          AuthForgotPasswordRequested(_emailController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.forgotPasswordEmailSent != current.forgotPasswordEmailSent,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<AuthBloc>().add(const AuthErrorCleared());
          } else if (state.forgotPasswordEmailSent) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Password reset email sent')),
              );
            context.read<AuthBloc>().add(const AuthErrorCleared());
          }
        },
        builder: (context, state) {
          final isLoading = state.isLoading;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Enter your account email and we will send instructions.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Iconsax.sms),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final emailRegex = RegExp(r'.+@.+\..+');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isLoading ? null : _submit,
                          child: const Text('Send reset link'),
                        ),
                      ),
                    ],
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
