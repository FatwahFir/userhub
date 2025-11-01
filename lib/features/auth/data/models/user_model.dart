import '../../../../core/utils/url_utils.dart';
import '../../domain/entities/user.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String name;
  final String role;
  final String? avatarUrl;
  final String? phone;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        username: json['username']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
        avatarUrl: json['avatar_url']?.toString(),
        phone: json['phone']?.toString(),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );

  User toEntity() => User(
        id: id,
        username: username,
        email: email,
        name: name,
        role: role,
        avatarUrl: normalizeAvatarUrl(avatarUrl),
        phone: phone,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
        updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
      );
}
