import 'package:frontend/core/utils/api_service.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/core/utils/storage_service.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontend/features/auth/domain/entities/user.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;
  final ApiService apiService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
    required this.apiService,
  });

  @override
  Future<Either<Failure, User>> register(String email, String password) async {
    final result = await remoteDataSource.register(email, password);
    if (result.isLeft()) {
      return Either.left(result.left!);
    }
    final userModel = result.right!;
    await storageService.saveAccessToken(userModel.accessToken);
    apiService.setAccessToken(userModel.accessToken);
    return Either.right(userModel.toEntity());
  }

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    final result = await remoteDataSource.login(email, password);
    if (result.isLeft()) {
      return Either.left(result.left!);
    }
    final userModel = result.right!;
    await storageService.saveAccessToken(userModel.accessToken);
    apiService.setAccessToken(userModel.accessToken);
    return Either.right(userModel.toEntity());
  }

  @override
  Future<Either<Failure, void>> logout() async {
    final result = await storageService.deleteAccessToken();
    if (result.isLeft()) {
      return Either.left(result.left!);
    }
    apiService.clearAccessToken();
    return Either.right(null);
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    final result = await storageService.hasAccessToken();
    if (result.isLeft()) {
      return Either.left(result.left!);
    }
    final hasToken = result.right!;
    if (hasToken) {
      final tokenResult = await storageService.getAccessToken();
      if (tokenResult.isLeft()) {
        return Either.left(tokenResult.left!);
      }
      apiService.setAccessToken(tokenResult.right!);
      return Either.right(true);
    }
    return Either.right(false);
  }
}
