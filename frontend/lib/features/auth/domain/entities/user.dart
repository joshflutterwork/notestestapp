import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String accessToken;

  const User({
    required this.id,
    required this.email,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [id, email, accessToken];
}
