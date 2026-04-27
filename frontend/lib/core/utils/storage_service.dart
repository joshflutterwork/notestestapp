import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/constants/storage_constants.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/core/utils/either.dart';

class StorageService {
  final FlutterSecureStorage _storage;

  StorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<Either<Failure, String>> getAccessToken() async {
    try {
      final token = await _storage.read(key: StorageConstants.accessToken);
      if (token == null) {
        return Either.left(
          const CacheFailure(message: 'No access token found'),
        );
      }
      return Either.right(token);
    } catch (e) {
      return Either.left(CacheFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> saveAccessToken(String token) async {
    try {
      await _storage.write(key: StorageConstants.accessToken, value: token);
      return Either.right(null);
    } catch (e) {
      return Either.left(CacheFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteAccessToken() async {
    try {
      await _storage.delete(key: StorageConstants.accessToken);
      return Either.right(null);
    } catch (e) {
      return Either.left(CacheFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> hasAccessToken() async {
    try {
      final token = await _storage.read(key: StorageConstants.accessToken);
      return Either.right(token != null);
    } catch (e) {
      return Either.left(CacheFailure(message: e.toString()));
    }
  }
}
