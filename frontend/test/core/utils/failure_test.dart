import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/failure.dart';

void main() {
  group('Failure', () {
    group('ServerFailure', () {
      test('should store message and statusCode', () {
        const failure = ServerFailure(message: 'Server error', statusCode: 500);

        expect(failure.message, 'Server error');
        expect(failure.statusCode, 500);
      });

      test('two failures with same props should be equal', () {
        const failure1 = ServerFailure(message: 'error', statusCode: 400);
        const failure2 = ServerFailure(message: 'error', statusCode: 400);

        expect(failure1, failure2);
      });

      test('two failures with different props should not be equal', () {
        const failure1 = ServerFailure(message: 'error1', statusCode: 400);
        const failure2 = ServerFailure(message: 'error2', statusCode: 500);

        expect(failure1, isNot(failure2));
      });
    });

    group('NetworkFailure', () {
      test('should store message without statusCode', () {
        const failure = NetworkFailure(message: 'No internet');

        expect(failure.message, 'No internet');
        expect(failure.statusCode, isNull);
      });
    });

    group('CacheFailure', () {
      test('should store message', () {
        const failure = CacheFailure(message: 'Cache miss');

        expect(failure.message, 'Cache miss');
      });
    });

    group('ValidationFailure', () {
      test('should store message', () {
        const failure = ValidationFailure(message: 'Invalid input');

        expect(failure.message, 'Invalid input');
      });
    });
  });
}
