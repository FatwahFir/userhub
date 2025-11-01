import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/url_utils.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class UserModel {
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String username;
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
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

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

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
