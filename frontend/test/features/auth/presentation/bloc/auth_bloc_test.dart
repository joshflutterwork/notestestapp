import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/core/utils/either.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/core/utils/usecase.dart';
import 'package:frontend/features/auth/domain/entities/user.dart';
import 'package:frontend/features/auth/domain/usecases/login.dart';
import 'package:frontend/features/auth/domain/usecases/logout.dart';
import 'package:frontend/features/auth/domain/usecases/register.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';

// Mocks
class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

// Fakes for fallback values
class FakeLoginParams extends Fake implements LoginParams {}

class FakeRegisterParams extends Fake implements RegisterParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  const tUser = User(
    id: 'user_1',
    email: 'test@example.com',
    accessToken: 'token_123',
  );

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
    );
  });

  tearDown(() => authBloc.close());

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  group('LoginEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(() => mockLoginUseCase(any()))
            .thenAnswer((_) async => Either.right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const LoginEvent(email: 'test@example.com', password: 'password123'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having(
          (s) => s.user.email,
          'user email',
          'test@example.com',
        ),
      ],
      verify: (_) {
        verify(() => mockLoginUseCase(any())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer(
          (_) async => Either.left(
            const ServerFailure(message: 'Invalid credentials', statusCode: 401),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const LoginEvent(email: 'test@example.com', password: 'wrong'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (s) => s.message,
          'error message',
          'Invalid credentials',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when network error occurs',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer(
          (_) async => Either.left(
            const NetworkFailure(message: 'No internet connection'),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const LoginEvent(email: 'test@example.com', password: 'password123'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (s) => s.message,
          'error message',
          'No internet connection',
        ),
      ],
    );
  });

  group('RegisterEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when registration succeeds',
      build: () {
        when(() => mockRegisterUseCase(any()))
            .thenAnswer((_) async => Either.right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const RegisterEvent(email: 'new@example.com', password: 'password123'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
      verify: (_) {
        verify(() => mockRegisterUseCase(any())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when registration fails',
      build: () {
        when(() => mockRegisterUseCase(any())).thenAnswer(
          (_) async => Either.left(
            const ServerFailure(message: 'Email already exists', statusCode: 409),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const RegisterEvent(email: 'existing@example.com', password: 'password123'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (s) => s.message,
          'error message',
          'Email already exists',
        ),
      ],
    );
  });

  group('LogoutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when logout succeeds',
      build: () {
        when(() => mockLogoutUseCase(any()))
            .thenAnswer((_) async => Either.right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
      verify: (_) {
        verify(() => mockLogoutUseCase(any())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when logout fails',
      build: () {
        when(() => mockLogoutUseCase(any())).thenAnswer(
          (_) async => Either.left(
            const CacheFailure(message: 'Failed to clear token'),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (s) => s.message,
          'error message',
          'Failed to clear token',
        ),
      ],
    );
  });
}
