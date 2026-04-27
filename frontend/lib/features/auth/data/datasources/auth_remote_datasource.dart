import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/utils/api_service.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, UserModel>> register(String email, String password);
  Future<Either<Failure, UserModel>> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<Either<Failure, UserModel>> register(String email, String password) {
    return apiService.post(ApiConstants.register, {
      'email': email,
      'password': password,
    }, (data) => UserModel.fromJson(data));
  }

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) {
    return apiService.post(ApiConstants.login, {
      'email': email,
      'password': password,
    }, (data) => UserModel.fromJson(data));
  }
}
