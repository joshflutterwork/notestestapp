import 'package:frontend/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.accessToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>;
    return UserModel(
      id: userData['id'] as String,
      email: userData['email'] as String,
      accessToken: json['access_token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'user': {'id': id, 'email': email},
    };
  }

  User toEntity() {
    return User(id: id, email: email, accessToken: accessToken);
  }
}
