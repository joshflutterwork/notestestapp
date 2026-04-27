import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/either.dart';

void main() {
  group('Either', () {
    group('constructor', () {
      test('left should store left value and be identified as left', () {
        final either = Either<String, int>.left('error');

        expect(either.isLeft(), true);
        expect(either.isRight(), false);
        expect(either.left, 'error');
        expect(either.right, isNull);
      });

      test('right should store right value and be identified as right', () {
        final either = Either<String, int>.right(42);

        expect(either.isLeft(), false);
        expect(either.isRight(), true);
        expect(either.right, 42);
        expect(either.left, isNull);
      });

      test('right(null) should still be identified as Right', () {
        final either = Either<String, void>.right(null);

        expect(either.isRight(), true);
        expect(either.isLeft(), false);
      });

      test('left(null) should still be identified as Left', () {
        final either = Either<String?, int>.left(null);

        expect(either.isLeft(), true);
        expect(either.isRight(), false);
      });
    });

    group('fold', () {
      test('should call onLeft callback for Left value', () {
        final either = Either<String, int>.left('error');

        final result = either.fold(
          (l) => 'Left: $l',
          (r) => 'Right: $r',
        );

        expect(result, 'Left: error');
      });

      test('should call onRight callback for Right value', () {
        final either = Either<String, int>.right(42);

        final result = either.fold(
          (l) => 'Left: $l',
          (r) => 'Right: $r',
        );

        expect(result, 'Right: 42');
      });

      test('fold should handle Right(null) correctly', () {
        final either = Either<String, void>.right(null);

        final result = either.fold(
          (l) => 'Left',
          (r) => 'Right',
        );

        expect(result, 'Right');
      });

      test('fold should return different types', () {
        final left = Either<String, int>.left('error');
        final right = Either<String, int>.right(42);

        final leftResult = left.fold((l) => 0, (r) => r);
        final rightResult = right.fold((l) => 0, (r) => r);

        expect(leftResult, 0);
        expect(rightResult, 42);
      });
    });
  });
}
