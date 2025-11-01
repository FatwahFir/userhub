import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String name;
  final String role;
  final String? avatarUrl;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        name,
        role,
        avatarUrl,
        phone,
        createdAt,
        updatedAt,
      ];
}
