import 'package:test/test.dart';
import 'package:daxle/src/either.dart';

void main() {
  group('Either<L, R> Tests', () {
    test('Left constructor should return a Left value', () {
      final either = Either<String, int>.left('Error');
      expect(either.isLeft, true);
      expect(either.isRight, false);
      expect((either as Left).value, 'Error');
    });

    test('Right constructor should return a Right value', () {
      final either = Either<String, int>.right(42);
      expect(either.isLeft, false);
      expect(either.isRight, true);
      expect((either as Right).value, 42);
    });

    test('unwrap() should return the Right value', () {
      final either = Either<String, int>.right(42);
      expect(either.unwrap(), 42);
    });

    test('unwrap() should throw a StateError if Left', () {
      final either = Either<String, int>.left('Error');
      expect(() => either.unwrap(), throwsStateError);
    });

    test('unwrapLeft() should return the Left value', () {
      final either = Either<String, int>.left('Error');
      expect(either.unwrapLeft(), 'Error');
    });

    test('unwrapLeft() should throw a StateError if Right', () {
      final either = Either<String, int>.right(42);
      expect(() => either.unwrapLeft(), throwsStateError);
    });

    test('map() should apply function to Right value', () {
      final either = Either<String, int>.right(5);
      final result = either.map((x) => x * 2);
      expect(result.unwrap(), 10);
    });

    test('map() should not apply function if Left', () {
      final either = Either<String, int>.left('Error');
      final result = either.map((x) => x * 2);
      expect(result.unwrapLeft(), 'Error');
    });

    test('mapLeft() should apply function to Left value', () {
      final either = Either<String, int>.left('Error');
      final result = either.mapLeft((x) => 'Mapped: $x');
      expect(result.unwrapLeft(), 'Mapped: Error');
    });

    test('mapLeft() should not apply function if Right', () {
      final either = Either<String, int>.right(42);
      final result = either.mapLeft((x) => 'Mapped: $x');
      expect(result.unwrap(), 42);
    });

    test('flatMap() should apply function to Right value', () {
      final either = Either<String, int>.right(5);
      final result = either.flatMap((x) => Either.right(x * 2));
      expect(result.unwrap(), 10);
    });

    test('flatMap() should return Left if initial is Left', () {
      final either = Either<String, int>.left('Error');
      final result = either.flatMap((x) => Either.right(x * 2));
      expect(result.unwrapLeft(), 'Error');
    });

    test('flatMapLeft() should apply function to Left value', () {
      final either = Either<String, int>.left('Error');
      final result = either.flatMapLeft((x) => Either.left('Mapped: $x'));
      expect(result.unwrapLeft(), 'Mapped: Error');
    });

    test('flatMapLeft() should not apply function if Right', () {
      final either = Either<String, int>.right(42);
      final result = either.flatMapLeft((x) => Either.left('Mapped: $x'));
      expect(result.unwrap(), 42);
    });

    test('fold() should execute onLeft if Left', () {
      final either = Either<String, int>.left('Error');
      final result = either.fold((l) => 'Left: $l', (r) => 'Right: $r');
      expect(result, 'Left: Error');
    });

    test('fold() should execute onRight if Right', () {
      final either = Either<String, int>.right(42);
      final result = either.fold((l) => 'Left: $l', (r) => 'Right: $r');
      expect(result, 'Right: 42');
    });

    test('getOrElse() should return Right value', () {
      final either = Either<String, int>.right(42);
      final result = either.getOrElse(() => 0);
      expect(result, 42);
    });

    test('getOrElse() should return orElse if Left', () {
      final either = Either<String, int>.left('Error');
      final result = either.getOrElse(() => 0);
      expect(result, 0);
    });

    test('getOrElseLeft() should return Left value', () {
      final either = Either<String, int>.left('Error');
      final result = either.getOrElseLeft(() => 'Fallback');
      expect(result, 'Error');
    });

    test('getOrElseLeft() should return orElse if Right', () {
      final either = Either<String, int>.right(42);
      final result = either.getOrElseLeft(() => 'Fallback');
      expect(result, 'Fallback');
    });

    test('contains() should return true if Right contains value', () {
      final either = Either<String, int>.right(42);
      final result = either.contains(42);
      expect(result, true);
    });

    test('contains() should return false if Right does not contain value', () {
      final either = Either<String, int>.right(42);
      final result = either.contains(10);
      expect(result, false);
    });

    test('containsLeft() should return true if Left contains value', () {
      final either = Either<String, int>.left('Error');
      final result = either.containsLeft('Error');
      expect(result, true);
    });

    test(
      'containsLeft() should return false if Left does not contain value',
      () {
        final either = Either<String, int>.left('Error');
        final result = either.containsLeft('Another error');
        expect(result, false);
      },
    );

    test('inspect() should apply function to Right value', () {
      final either = Either<String, int>.right(42);
      final result = either.inspect((r) => print('Right: $r'));
      expect(result.unwrap(), 42);
    });

    test('inspect() should not change Left value', () {
      final either = Either<String, int>.left('Error');
      final result = either.inspect((r) => print('Right: $r'));
      expect(result.unwrapLeft(), 'Error');
    });

    test('inspectLeft() should apply function to Left value', () {
      final either = Either<String, int>.left('Error');
      final result = either.inspectLeft((l) => print('Left: $l'));
      expect(result.unwrapLeft(), 'Error');
    });

    test('inspectLeft() should not change Right value', () {
      final either = Either<String, int>.right(42);
      final result = either.inspectLeft((l) => print('Left: $l'));
      expect(result.unwrap(), 42);
    });

    test('swap() should swap Left to Right and vice versa', () {
      final eitherLeft = Either<String, int>.left('Error');
      final swappedLeft = eitherLeft.swap();
      expect(swappedLeft.unwrap(), 'Error');
      expect(swappedLeft.isLeft, false);
      expect(swappedLeft.isRight, true);

      final eitherRight = Either<String, int>.right(42);
      final swappedRight = eitherRight.swap();
      expect(swappedRight.unwrapLeft(), 42);
      expect(swappedRight.isLeft, true);
      expect(swappedRight.isRight, false);
    });

    test('toResult() should convert Right to Ok', () {
      final either = Either<String, int>.right(42);
      final result = either.toResult((err) => FormatException(err));
      expect(result.isOk, true);
      expect(result.unwrap(), 42);
    });

    test('toResult() should convert Left to Err', () {
      final either = Either<String, int>.left('Error');
      final result = either.toResult((err) => FormatException(err));
      expect(result.isErr, true);
      expect(() => result.unwrap(), throwsFormatException);
    });

    test(
      'toResult() should thrown when transofrming Left to Err without mapErr callback',
      () {
        final either = Either<String, int>.left('Error');
        expect(() => either.toResult(), throwsStateError);
      },
    );

    test('toOption() should convert Right to Ok', () {
      final either = Either<String, int>.right(42);
      final result = either.toOption();
      expect(result.isSome, true);
      expect(result.unwrap(), 42);
    });

    test('toOption() should convert Left to Err', () {
      final either = Either<String, int>.left('Error');
      final result = either.toOption();
      expect(result.isNone, true);
      expect(() => result.unwrap(), throwsStateError);
    });

    test('Left with complex type should be handled correctly', () {
      final either = Either<Map<String, dynamic>, String>.left({
        'message': 'failure',
      });
      expect(either.unwrapLeft(), {'message': 'failure'});
    });

    test('Right with nullable type should work', () {
      final either = Either<String, int?>.right(null);
      expect(either.unwrap(), null);
    });

    test('orElse() should return the Right value if it exists', () {
      final either = Either<String, int>.right(42);
      final result = either.orElse(() => .new(0));
      expect(result.unwrap(), 42);
    });

    test('orElse() should use the fallback if Left', () {
      final either = Either<String, int>.left('Error');
      final result = either.orElse(() => .new(0));
      expect(result.unwrap(), 0);
    });

    test('orElse() should return the correct fallback value', () {
      final either = Either<String, int>.left('Error');
      final result = either.orElse(() => .new(100));
      expect(result.unwrap(), 100);
    });

    test('orElseLeft() should return the Left value if it exists', () {
      final either = Either<String, int>.left('Error');
      final result = either.orElseLeft(() => .new('Fallback'));
      expect(result.unwrapLeft(), 'Error');
    });

    test('orElseLeft() should use the fallback if Right', () {
      final either = Either<String, int>.right(42);
      final result = either.orElseLeft(() => .new('Fallback'));
      expect(result.unwrapLeft(), 'Fallback');
    });

    test('orElseLeft() should return the correct fallback value', () {
      final either = Either<String, int>.right(42);
      final result = either.orElseLeft(() => .new('No Error'));
      expect(result.unwrapLeft(), 'No Error');
    });
  });
}
