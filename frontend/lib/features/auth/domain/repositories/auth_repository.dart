import 'package:frontend/core/utils/either.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> register(String email, String password);
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> isLoggedIn();
}
