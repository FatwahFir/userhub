import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/usecases/update_profile.dart';
import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  File? _avatar;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _populate(User? user) {
    if (user == null || _initialized) return;
    _initialized = true;
    _usernameController.text = user.username;
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _avatar = File(picked.path);
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ProfileBloc>().add(
          ProfileUpdated(
            UpdateProfilePayload(
              username: _usernameController.text.trim(),
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              avatarPath: _avatar?.path,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
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
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (prev, curr) =>
              prev.errorMessage != curr.errorMessage ||
              prev.updateSuccess != curr.updateSuccess,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            } else if (state.updateSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
              context.read<ProfileBloc>().add(const ProfileErrorCleared());
            }
          },
          builder: (context, state) {
            final user = state.user ?? context.read<AuthBloc>().state.user;
            _populate(user);
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Align(
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: _pickAvatar,
                                          child: CircleAvatar(
                                            radius: 56,
                                            backgroundImage: _avatar != null
                                                ? FileImage(_avatar!)
                                                : (user.avatarUrl != null
                                                    ? NetworkImage(user.avatarUrl!)
                                                    : null) as ImageProvider<
                                                    Object>?,
                                            backgroundColor:
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(.08),
                                            child: _avatar == null &&
                                                    user.avatarUrl == null
                                                ? Icon(Iconsax.user,
                                                    size: 44,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)
                                                : null,
                                          ),
                                        ),
                                        Positioned(
                                          right: 4,
                                          bottom: 4,
                                          child: Material(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            shape: const CircleBorder(),
                                            child: InkWell(
                                              onTap: _pickAvatar,
                                              customBorder: const CircleBorder(),
                                              child: const Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Icon(
                                                  Iconsax.camera,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Align(
                                    child: TextButton(
                                      onPressed: _pickAvatar,
                                      child: const Text('Change avatar'),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Personal details',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _usernameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Username',
                                      prefixIcon: Icon(Iconsax.user),
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Required'
                                            : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Full Name',
                                      prefixIcon: Icon(Iconsax.profile_circle),
                                    ),
                                    validator: (value) => value == null ||
                                            value.isEmpty
                                        ? 'Required'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Iconsax.sms),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      final emailRegex = RegExp(r'.+@.+\..+');
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone',
                                      prefixIcon: Icon(Iconsax.call),
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  FilledButton(
                                    onPressed: state.isSaving ? null : _submit,
                                    child: const Text('Save changes'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (state.isSaving)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x55000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
