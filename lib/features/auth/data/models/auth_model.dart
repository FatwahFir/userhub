import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/auth.dart';
import 'user_model.dart';

part 'auth_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AuthModel {
  @JsonKey(defaultValue: '')
  final String token;
  final UserModel user;

  AuthModel({required this.token, required this.user});

  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthModelToJson(this);

  Auth toEntity() => Auth(token: token, user: user.toEntity());
}
