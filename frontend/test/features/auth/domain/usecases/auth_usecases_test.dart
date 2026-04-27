import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/auth/domain/entities/user.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/login.dart';
import 'package:frontend/features/auth/domain/usecases/register.dart';
import 'package:frontend/features/auth/domain/usecases/logout.dart';
import 'package:frontend/core/utils/usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  const tUser = User(
    id: 'user_1',
    email: 'test@example.com',
    accessToken: 'token_123',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('LoginUseCase', () {
    late LoginUseCase useCase;

    setUp(() {
      useCase = LoginUseCase(mockRepository);
    });

    test('should call repository.login with correct params', () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => Either.right(tUser));

      const params = LoginParams(email: 'test@example.com', password: 'pass');
      await useCase(params);

      verify(() => mockRepository.login('test@example.com', 'pass')).called(1);
    });

    test('should return User on success', () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => Either.right(tUser));

      const params = LoginParams(email: 'test@example.com', password: 'pass');
      final result = await useCase(params);

      expect(result.isRight(), true);
      expect(result.right, tUser);
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.login(any(), any())).thenAnswer(
        (_) async =>
            Either.left(const ServerFailure(message: 'Invalid credentials')),
      );

      const params = LoginParams(email: 'test@example.com', password: 'wrong');
      final result = await useCase(params);

      expect(result.isLeft(), true);
      expect(result.left?.message, 'Invalid credentials');
    });
  });

  group('RegisterUseCase', () {
    late RegisterUseCase useCase;

    setUp(() {
      useCase = RegisterUseCase(mockRepository);
    });

    test('should call repository.register with correct params', () async {
      when(() => mockRepository.register(any(), any()))
          .thenAnswer((_) async => Either.right(tUser));

      const params =
          RegisterParams(email: 'new@example.com', password: 'pass123');
      await useCase(params);

      verify(() => mockRepository.register('new@example.com', 'pass123'))
          .called(1);
    });

    test('should return User on success', () async {
      when(() => mockRepository.register(any(), any()))
          .thenAnswer((_) async => Either.right(tUser));

      const params =
          RegisterParams(email: 'new@example.com', password: 'pass123');
      final result = await useCase(params);

      expect(result.isRight(), true);
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.register(any(), any())).thenAnswer(
        (_) async =>
            Either.left(const ServerFailure(message: 'Email exists')),
      );

      const params =
          RegisterParams(email: 'existing@example.com', password: 'pass');
      final result = await useCase(params);

      expect(result.isLeft(), true);
      expect(result.left?.message, 'Email exists');
    });
  });

  group('LogoutUseCase', () {
    late LogoutUseCase useCase;

    setUp(() {
      useCase = LogoutUseCase(mockRepository);
    });

    test('should call repository.logout', () async {
      when(() => mockRepository.logout())
          .thenAnswer((_) async => Either.right(null));

      await useCase(const NoParams());

      verify(() => mockRepository.logout()).called(1);
    });

    test('should return void on success', () async {
      when(() => mockRepository.logout())
          .thenAnswer((_) async => Either.right(null));

      final result = await useCase(const NoParams());

      expect(result.isRight(), true);
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.logout()).thenAnswer(
        (_) async =>
            Either.left(const CacheFailure(message: 'Storage error')),
      );

      final result = await useCase(const NoParams());

      expect(result.isLeft(), true);
      expect(result.left?.message, 'Storage error');
    });
  });
}
