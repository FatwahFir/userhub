import '../../domain/entities/auth.dart';
import 'user_model.dart';

class AuthModel {
  final String token;
  final UserModel user;

  AuthModel({required this.token, required this.user});

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
        token: json['token']?.toString() ?? '',
        user: UserModel.fromJson(
          (json['user'] as Map<String, dynamic>? ?? <String, dynamic>{}),
        ),
      );

  Auth toEntity() => Auth(token: token, user: user.toEntity());
}
